//
//  NetworkManager.swift
//  GitHubApp
//
//  Created by Rodianov on 02.07.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import Foundation

final class NetworkManager {
  
  let scheme = "https"
  let host = "api.github.com"
  let searchRepoPath = "/search/repositories"
  let defaultHeaders = [
    "Content-Type" : "application/json",
    "Accept" : "application/vnd.github.v3+json"
  ]
  
  func makeSearchRequest(repoName: String, language: String, orderType: String) -> URLRequest? {
     var urlComponents = URLComponents()
     
     urlComponents.scheme = scheme
     urlComponents.host = host
     urlComponents.path = searchRepoPath

         urlComponents.queryItems = [
           URLQueryItem(name: "q", value: "\(repoName)+language:\(language)"),
           URLQueryItem(name: "sort", value: "stars"),
           URLQueryItem(name: "order", value: orderType)
         ]
     
     guard let url = urlComponents.url else {
       return nil
     }
     
     var request = URLRequest(url: url)
     request.allHTTPHeaderFields = defaultHeaders
     
     return request
   }
  
  func performRequest(request: URLRequest, session: URLSession, completionHandler: @escaping (Data)-> Void) {
  
    let dataTask = session.dataTask(with: request) {
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
  
  func parseJSON<T: Codable>(jsonData: Data, toType: T.Type) -> T? {
    let decoder = JSONDecoder()

    guard let result = try? decoder.decode(T.self, from: jsonData) else {
      print("data decoding failed")
      return nil
    }

    return result
  } 
}
