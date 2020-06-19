//
//  RepoTableViewCell.swift
//  GitHubApp
//
//  Created by Rodianov on 13.06.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import UIKit
import Kingfisher

final class RepoTableViewCell: UITableViewCell {
  static let identifier = "repoCell"
  
  var repo: Repository? {
    didSet {
      repoNamelabel.text = repo?.name
      repoInfoLabel.text = repo?.description
      userNameLabel.text = repo?.owner?.login
      guard let avatarURL = repo?.owner?.avatarURL else {return}
      let url = URL(string: avatarURL)
      avatarImageView.kf.setImage(with: url)
      guard let htmlString = repo?.htmlURLString else {return}
      htmlURL = URL(string: htmlString)
    }
  }
  
  var htmlURL: URL?
  
  private let avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 20
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private let repoNamelabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 20)
    return label
  }()
  
  private let repoInfoLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 18)
    label.numberOfLines = 2
    return label
  }()
  
  private let userNameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 10)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RepoTableViewCell {
  private func setupLayout() {
    contentView.addSubview(repoNamelabel)
    contentView.addSubview(repoInfoLabel)
    contentView.addSubview(userNameLabel)
    contentView.addSubview(avatarImageView)
    
    repoNamelabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(10)
      $0.leading.equalToSuperview().inset(25)
    }
    
    repoInfoLabel.snp.makeConstraints {
      $0.top.equalTo(repoNamelabel.snp.bottom).inset(-6)
      $0.leading.equalTo(repoNamelabel.snp.leading)
      $0.trailing.equalTo(avatarImageView.snp.leading).inset(-10)
    }
    
    userNameLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(12)
      $0.centerX.equalTo(avatarImageView.snp.centerX)
    }
    
    avatarImageView.snp.makeConstraints {
      $0.top.equalTo(userNameLabel.snp.bottom).inset(-10)
      $0.trailing.equalToSuperview().inset(30)
      $0.width.height.equalTo(40)
    }
  }
}
