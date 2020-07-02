//
//  SearchResultViewController.swift
//  GitHubApp
//
//  Created by Rodianov on 13.06.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import Foundation
import UIKit

final class SearchResultViewController: UIViewController {
  
  private var repositoriesArray: [Repository]
  
  private lazy var resultCountLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 20)
    label.text = "Repositories found: \(self.repositoriesArray.count)"
    return label
  }()
  
  private lazy var repoListTableView: UITableView = {
    let tableView = UITableView()
    tableView.register(RepoTableViewCell.self, forCellReuseIdentifier: RepoTableViewCell.identifier)
    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()
  
  init(searchResult: [Repository]) {
    self.repositoriesArray = searchResult
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupLayout()
  }
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return repositoriesArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: RepoTableViewCell.identifier, for: indexPath) as? RepoTableViewCell else {return UITableViewCell()}
    
    cell.repo = repositoriesArray[indexPath.row]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let htmlString = repositoriesArray[indexPath.row].htmlURLString,
      let url = URL(string: htmlString)
      else {return}
    
    navigationController?.pushViewController(RepoWebViewController(url: url), animated: true)
  }
}

extension SearchResultViewController {
  private func setupLayout() {
    view.addSubview(resultCountLabel)
    view.addSubview(repoListTableView)
    
    resultCountLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
      $0.leading.equalToSuperview().inset(16)
    }
    
    repoListTableView.snp.makeConstraints {
      $0.top.equalTo(resultCountLabel.snp.bottom).inset(-10)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
}
