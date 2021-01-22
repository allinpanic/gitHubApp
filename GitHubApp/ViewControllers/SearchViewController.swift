//
//  SearchViewController.swift
//  GitHubApp
//
//  Created by Rodianov on 06.06.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher

final class SearchViewController: UIViewController {  
  var user: GitUser
  private let sharedSession = URLSession.shared
  private let networkManager = NetworkManager()
  
// MARK: - UI properties
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
// MARK: - Inits
  
  init(user: GitUser) {
    self.user = user
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    guard let userName = user.login else {return}
    userNameLabel.text = "Hello \(userName)"
    guard let avatarURL = user.avatarURL else {return}
    let url = URL(string: avatarURL)
    userAvatarImageView.kf.setImage(with: url)
    
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
// MARK: - TextFieldDelegate, Keyboard handler

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
// MARK: - Search Button Pressed

extension SearchViewController {
  @objc private func searchButtonPressed() {
    dismissKeyboard()
    
    var orderType: String
    if sortingTypeSegmentControl.selectedSegmentIndex == 0 {
      orderType = "asc"
    } else {
      orderType = "desc"
    }
    
    guard let repoName = repositoryNameTextField.text,
      let language = languageTextField.text else {return}
    
    if !repoName.isEmpty{
      guard let searchRequest = networkManager.makeSearchRequest(repoName: repoName,
                                                                 language: language,
                                                                 orderType: orderType) else {return}
      
      networkManager.performRequest(request: searchRequest, session: sharedSession) {
        [weak self] (data, response) in
        
        guard let repositoriesResult = self?.networkManager.parseJSON(jsonData: data, toType: SearchResult.self) else {
          return
        }
        
        DispatchQueue.main.async {
          self?.navigationController?.pushViewController(SearchResultViewController(searchResult: repositoriesResult.items),
                                                         animated: true)
        }
      }
    } else {
      let alert = UIAlertController(title: "Repository name field is empty",
                                    message: "Specify a name and try again",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      present(alert, animated: true, completion: nil)
    }
  }
}
