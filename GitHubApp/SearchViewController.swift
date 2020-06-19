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
 //MARK: - Network Properties
  let scheme = "https"
  let host = "api.github.com"
  let searchRepoPath = "/search/repositories"
  let defaultHeaders = [
    "Content-Type" : "application/json",
    "Accept" : "application/vnd.github.v3+json"
  ]
  
  let sharedSession = URLSession.shared
  
//MARK: - UI properties
  private let userNameLabel: UILabel = {
    let label = UILabel()
    label.text = "UserName"
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .black
    return label
  }()
  
  private let userAvatarImageView: UIImageView = {
    let image = UIImageView()
    image.backgroundColor = .systemGray3
    image.layer.cornerRadius = 50
    image.contentMode = .scaleAspectFill
    return image
  }()
  
  private let searchLabel: UILabel = {
    let label = UILabel()
    label.text = "Search repository"
    label.font = .boldSystemFont(ofSize: 24)
    return label
  }()
  
  private lazy var repositoryNameTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "repository name"
    textField.borderStyle = .roundedRect
    textField.delegate = self
    textField.returnKeyType = .done
    return textField
  }()
  
  private lazy var languageTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "language"
    textField.borderStyle = .roundedRect
    textField.delegate = self
    textField.returnKeyType = .done
    return textField
  }()
  
  private let sortingTypeSegmentControl: UISegmentedControl = {
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
  
  private lazy var startSearchButton: UIButton = {
    let button = UIButton()
    button.setTitle("Start Search", for: .normal)
    button.titleLabel?.font = .boldSystemFont(ofSize: 28)
    button.setTitleColor(.systemBlue, for: .normal)
    button.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
    return button
  }()
//MARK: - ViewDidLoad
  
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
// MARK: - setupLAyout

extension SearchViewController {
  private func setupLayout() {
    let views = [userNameLabel, userAvatarImageView, searchLabel, repositoryNameTextField,
                 languageTextField, sortingTypeSegmentControl, startSearchButton]
    views.forEach({view.addSubview($0)})
    
    userNameLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(60)
      $0.centerX.equalToSuperview()
    }
    
    userAvatarImageView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(userNameLabel.snp.bottom).inset(-20)
      $0.width.height.equalTo(100)
    }
    
    searchLabel.snp.makeConstraints {
      $0.top.equalTo(userAvatarImageView.snp.bottom).inset(-35)
      $0.centerX.equalToSuperview()
    }
    
    repositoryNameTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(50)
      $0.top.equalTo(searchLabel.snp.bottom).inset(-20)
    }
    
    languageTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(50)
      $0.top.equalTo(repositoryNameTextField.snp.bottom).inset(-15)
    }
    
    sortingTypeSegmentControl.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(50)
      $0.top.equalTo(languageTextField.snp.bottom).inset(-30)
    }
    
    startSearchButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(sortingTypeSegmentControl.snp.bottom).inset(-40)
    }    
  }
}
//MARK: - TextFieldDelegate, Keyboard handler

extension SearchViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    dismissKeyboard()
    return true
  }
  
  private func handleKeyboard() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}
//MARK: - Network Methods

extension SearchViewController {
  private func makeSearchRequest() -> URLRequest? {
    var urlComponents = URLComponents()
    var orderType: String
    
    urlComponents.scheme = scheme
    urlComponents.host = host
    urlComponents.path = searchRepoPath
    
    if sortingTypeSegmentControl.selectedSegmentIndex == 0 {
      orderType = "asc"
    } else {
      orderType = "desc"
    }
    
    if let repoName = repositoryNameTextField.text,
      let language = languageTextField.text {
      
      if !repoName.isEmpty {
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
  
  private func performSearchRequest(completionHandler: @escaping (Data)-> Void) {
    guard let urlRequest = makeSearchRequest() else {return}
    
    let dataTask = sharedSession.dataTask(with: urlRequest) {
      data, response, error in
      
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
      
      completionHandler(data)
    }
    
    dataTask.resume()
  }
}
//MARK: - Search Button Pressed

extension SearchViewController {
  @objc private func searchButtonPressed() {
    dismissKeyboard()
    
    performSearchRequest(completionHandler: {
      [weak self] jsonData in
      print(jsonData)
      
      guard let repositoriesResult = self?.parseJson(jsonData: jsonData) else {return}
      
      DispatchQueue.main.async {
        self?.navigationController?.pushViewController(SearchResultViewController(searchResult: repositoriesResult), animated: true)
      }
    })
  }
  
  func parseJson(jsonData: Data) -> [Repository] {    
    let decoder = JSONDecoder()
    
    guard let searchResult = try? decoder.decode(SearchResult.self, from: jsonData) else {
      print("data decoding failed")
      return []      
    }
    
    return searchResult.items
  }
}
