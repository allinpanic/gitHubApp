//
//  ViewController.swift
//  GitHubApp
//
//  Created by Rodianov on 28.05.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import LocalAuthentication

final class AuthoriseViewController: UIViewController {
// MARK: - Private Properties
  private let service = "githubApp"
  
  private let gitHubLogoUrl = "https://upload.wikimedia.org/wikipedia/commons/5/54/GitHub_Logo.png"
  
  private let sharedSession = URLSession.shared
  private let networkManager = NetworkManager()
  
  private lazy var logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.kf.indicatorType = .activity
    let url = URL(string: gitHubLogoUrl)
    imageView.kf.setImage(with: url)
    return imageView
  }()
  
  private let userNameTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "username"
    return textField
  }()
  
  private let passwordTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "password"
    textField.isSecureTextEntry = true
    return textField
  }()
  
  private let loginButton: UIButton = {
    let button = UIButton()
    button.setTitle("Login", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.showsTouchWhenHighlighted = true
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    return button
  }()
// MARK: - ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    setupLayout()
    
    handleKeyboard()
    
    if readKeychain(service: service) != nil {
      authenticateUser()      
    }
  }    
}
// MARK: - setupLayout

extension AuthoriseViewController {
  private func setupLayout() {
    view.addSubview(logoImageView)
    view.addSubview(userNameTextField)
    view.addSubview(passwordTextField)
    view.addSubview(loginButton)
    
    logoImageView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(35)
      $0.height.equalTo(130)
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(65)
    }
    
    userNameTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(50)
      $0.top.equalTo(logoImageView.snp.bottom).inset(-90)
    }
    
    passwordTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(50)
      $0.top.equalTo(userNameTextField.snp.bottom).inset(-25)
    }
    
    loginButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(passwordTextField.snp.bottom).inset(-40)
    }
  }
}
// MARK: - Handle Keyboard

extension AuthoriseViewController {
  private func handleKeyboard() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}
// MARK: - LoginButtonHandler

extension AuthoriseViewController {
  @objc private func loginButtonTapped() {
    
    guard let userName = userNameTextField.text,
      let password = passwordTextField.text else {return}
    
    if !userName.isEmpty,
      !password.isEmpty {
      
      let userNamePassword = "\(userName):\(password)"
      
      guard let userNamePasswordBase64Data = userNamePassword.data(using: .utf8) else {return}
      let userNamePasswordBase64String = userNamePasswordBase64Data.base64EncodedString()
      
      let url = URL(string: "https://api.github.com/user")
      
      var request = URLRequest(url: url!)
      request.addValue("Basic \(userNamePasswordBase64String)",
        forHTTPHeaderField: "Authorization")
      
      networkManager.performRequest(request: request, session: sharedSession) { [weak self] data, response in
        guard let response = response as? HTTPURLResponse else {return}
        let statusCode = response.statusCode
        
        guard let service = self?.service else {return}
        
        if statusCode == 200 {
          let result = self?.saveToKeychain(passwordData: userNamePasswordBase64Data, service: service) ?? false
          
          if result {
            print("password saved successfully")
          } else {
            print("can't save password")
          }
          
          guard let gitUser = self?.networkManager.parseJSON(jsonData: data,
                                                             toType: GitUser.self) else {return}
          
          DispatchQueue.main.async {
            self?.navigationController?.pushViewController(SearchViewController(user: gitUser), animated: true)
          }
        } else {
          DispatchQueue.main.async {
            let alertVC = UIAlertController(title: "Authorization failed", message: "Try again", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self?.present(alertVC, animated: true, completion: nil)
          }
        }
      }
    } else {
      let alertVC = UIAlertController(title: "Empty field", message: "Specify username or passwod", preferredStyle: .alert)
      alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      self.present(alertVC, animated: true, completion: nil)
    }
  }
}
// MARK: - Keychain Functions

extension AuthoriseViewController {
  private func keychainQuery (service: String, account: String?) -> [String: AnyObject] {
    var query = [String: AnyObject]()
    query[kSecClass as String] = kSecClassGenericPassword
    query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
    query[kSecAttrService as String] = service as AnyObject
    
    if let account = account {
      query[kSecAttrAccount as String] = account as AnyObject
    }
    return query
  }
  
  private func readKeychain(service: String) -> Data? {
    var query = keychainQuery(service: service, account: nil)
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    query[kSecReturnData as String] = kCFBooleanTrue
    query[kSecReturnAttributes as String] = kCFBooleanTrue
    
    var queryResult: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(&queryResult))
    
    if status != noErr {
      return nil
    }
    
    guard let item = queryResult as? [String : AnyObject],
      let passwordData = item[kSecValueData as String] as? Data else {
        return nil
    }
    return passwordData
  }
  
  private func saveToKeychain(passwordData: Data, service: String) -> Bool {
    if readKeychain(service: service) != nil {
      var attributesToUpdate = [String: AnyObject]()
      attributesToUpdate[kSecValueData as String] = passwordData as AnyObject
      
      let query = keychainQuery(service: service, account: nil)
      let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
      return status == noErr
    }
    
    var item = keychainQuery(service: service, account: nil)
    item[kSecValueData as String] = passwordData as AnyObject
    let status = SecItemAdd(item as CFDictionary, nil)
    return status == noErr
  }
}
// MARK: - TouchId functions

extension AuthoriseViewController {
  private func authenticateUser() {
    let authContext = LAContext()
    setupAuthContext(context: authContext)
    
    let reason = "Use for fast and safe authentication in your app"
    var authError: NSError?
    
    if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
      authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
      { [unowned self] (success, evaluateError) in
        if success {
          guard let userinfoData = self.readKeychain(service: self.service) else {return}
          let userInfoString = userinfoData.base64EncodedString()
          
          let url = URL(string: "https://api.github.com/user")
          
          var request = URLRequest(url: url!)
          request.addValue("Basic \(userInfoString)",
            forHTTPHeaderField: "Authorization")
          
          self.networkManager.performRequest(request: request, session: self.sharedSession)
          { [weak self] data, response in
            guard let gitUser = self?.networkManager.parseJSON(jsonData: data,
                                                               toType: GitUser.self) else {return}
            
            DispatchQueue.main.async {
              self?.navigationController?.pushViewController(SearchViewController(user: gitUser), animated: true)
            }
          }
        } else {
          if let error = evaluateError {
            print(error.localizedDescription)
          }
        }
      }
    } else {
      if let error = authError {
        print(error.localizedDescription)
      }
    }
  }
  
  private func setupAuthContext(context: LAContext) {
    context.localizedReason = "Use for fast and safe authentication in your app"
    context.localizedCancelTitle = "Cancel"
    context.localizedFallbackTitle = "Enter Password"
    
    context.touchIDAuthenticationAllowableReuseDuration = 600
  }
}
