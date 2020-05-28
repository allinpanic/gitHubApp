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

final class AuthoriseViewController: UIViewController {
  
  private let logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.kf.indicatorType = .activity
    let url = URL(string: "https://upload.wikimedia.org/wikipedia/commons/5/54/GitHub_Logo.png")
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    setupLayout()
    
    handleKeyboard()
  }    
}

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

extension AuthoriseViewController {
  private func handleKeyboard() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}

extension AuthoriseViewController {
  @objc private func loginButtonTapped() {
    print("login button tapped")
  }
}
