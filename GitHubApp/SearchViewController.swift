//
//  SearchViewController.swift
//  GitHubApp
//
//  Created by Rodianov on 06.06.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import UIKit
import Foundation

final class SearchViewController: UIViewController {
  
  let scheme = "https"
  let host = "api.github.com"
  let searchRepoPath = "/search/repositories"
  let defaultHeaders = [
    "Content-Type" : "application/json",
    "Accept" : "application/vnd.github.v3+json"
  ]
  
  let sharedSession = URLSession.shared
  
  // Название свойств с маленькой буквы
  private let UserNameLabel: UILabel = {
    let label = UILabel()
    label.text = "UserName"
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .black
    return label
  }()
  
  // Название свойств с маленькой буквы
  private let UserAvatarImageView: UIImageView = {
    let image = UIImageView()
    image.backgroundColor = .systemGray3
    image.layer.cornerRadius = 50
    image.contentMode = .scaleAspectFill
    return image
  }()
  
  // Название свойств с маленькой буквы
  private let SearchLabel: UILabel = {
    let label = UILabel()
    label.text = "Search repository"
    label.font = .boldSystemFont(ofSize: 24)
    return label
  }()
  
  private let repositoryNameTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "repository name"
    textField.borderStyle = .roundedRect
    return textField
  }()
  
  private let languageTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "language"
    textField.borderStyle = .roundedRect
    return textField
  }()
  
  // Название свойств с маленькой буквы
  private let SortingTypeSegmentControl: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: ["ascended", "descended"])
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.selectedSegmentTintColor = .systemGray3
    segmentedControl.backgroundColor = UIColor.white
    segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray],
                                            for: .normal)
    segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white],
                                            for: .selected)
    return segmentedControl
  }()
  
  // Название свойств с маленькой буквы
  private lazy var StartSearchButton: UIButton = {
    let button = UIButton()
    button.setTitle("Start Search", for: .normal)
    button.titleLabel?.font = .boldSystemFont(ofSize: 28)
    button.setTitleColor(.systemBlue, for: .normal)
    button.addTarget(self, action: #selector(performSearchRequest), for: .touchUpInside)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupLayout()
    handleKeyboard()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)    
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
}

extension SearchViewController {
  private func setupLayout() {
    let views = [UserNameLabel, UserAvatarImageView, SearchLabel, repositoryNameTextField,
                 languageTextField, SortingTypeSegmentControl, StartSearchButton]
    views.forEach({view.addSubview($0)})
    
    UserNameLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(60)
      $0.centerX.equalToSuperview()
    }
    
    UserAvatarImageView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(UserNameLabel.snp.bottom).inset(-25)
      $0.width.height.equalTo(100)
    }
    
    SearchLabel.snp.makeConstraints {
      $0.top.equalTo(UserAvatarImageView.snp.bottom).inset(-40)
      $0.centerX.equalToSuperview()
    }
    
    repositoryNameTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(50)
      $0.top.equalTo(SearchLabel.snp.bottom).inset(-20)
    }
    
    languageTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(50)
      $0.top.equalTo(repositoryNameTextField.snp.bottom).inset(-16)
    }
    
    SortingTypeSegmentControl.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(50)
      $0.top.equalTo(languageTextField.snp.bottom).inset(-30)
    }
    
    StartSearchButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(SortingTypeSegmentControl.snp.bottom).inset(-40)
    }    
  }
}

extension SearchViewController {
  private func handleKeyboard() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}

extension SearchViewController {
  private func makeSearchRequest() -> URLRequest? {
    var urlComponents = URLComponents()
    var orderType: String
    
    urlComponents.scheme = scheme
    urlComponents.host = host
    urlComponents.path = searchRepoPath
    
    if SortingTypeSegmentControl.selectedSegmentIndex == 0 {
      orderType = "asc"
    } else {
      orderType = "desc"
    }
    
    if let repoName = repositoryNameTextField.text,
      let language = languageTextField.text {
      
      // Форматирование поехало
      if !repoName.isEmpty
      {
      urlComponents.queryItems = [
        URLQueryItem(name: "q", value: "\(repoName)+language:\(language)"),
        URLQueryItem(name: "sort", value: "stars"),
        URLQueryItem(name: "order", value: orderType)
      ]
      } else {
        let alert = UIAlertController(title: "Repository name field is empty",
                                      message: "Specify a name and try again",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        return nil
      }
    }
    
    guard let url = urlComponents.url else {
      return nil
    }
    
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = defaultHeaders
    
    return request
  }
  
  @objc private func performSearchRequest() {
    guard let urlRequest = makeSearchRequest() else {return}
    
    let dataTask = sharedSession.dataTask(with: urlRequest) {
      data, response, error in
      
      // Форматирование поехало
        if let error = error {
          print(error.localizedDescription)
          return
        }
      
      if let httpResponse = response as? HTTPURLResponse {
        print("http status code: \(httpResponse.statusCode)")
      }
      
      guard let data = data else {
        print("no data received")
        return
      }
      
      guard let text = try? JSONSerialization.jsonObject(with: data, options: []) else {
        print("data encoding failed")
        return
      }
      
      print("received data: \n \(text)")
    }
    
    dataTask.resume()
  }
}
