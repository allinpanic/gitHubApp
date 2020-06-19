//
//  Repository.swift
//  GitHubApp
//
//  Created by Rodianov on 13.06.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import Foundation

struct SearchResult: Codable {
  var items: [Repository]
}

struct Repository: Codable {
  var name: String?
  var description: String?
  var owner: GitUser?
  var htmlURLString: String?
  
  private enum CodingKeys: String, CodingKey {
    case name
    case description
    case owner
    case htmlURLString = "html_url"
  }
}

struct GitUser: Codable {
  var avatarURL: String?
  var login: String?
  
  private enum CodingKeys: String, CodingKey {
    case avatarURL = "avatar_url"
    case login
  }
}
