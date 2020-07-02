//
//  RepoWebViewController.swift
//  GitHubApp
//
//  Created by Rodianov on 29.06.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import UIKit
import WebKit

final class RepoWebViewController: UIViewController, WKUIDelegate {
  var webView: WKWebView!
  var repoURL: URL
  
  init(url: URL) {
    self.repoURL = url    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    
    let webConfiguration = WKWebViewConfiguration()
    webView = WKWebView(frame: .zero, configuration: webConfiguration)
    webView.uiDelegate = self
    webView.navigationDelegate = self
    view = webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let urlRequest = URLRequest(url: repoURL)
    webView.load(urlRequest)
    webView.allowsBackForwardNavigationGestures = true
  }
}

extension RepoWebViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    let bgColorString = "document.body.style.background = '#ff8c69';"
    webView.evaluateJavaScript(bgColorString, completionHandler: nil)
  }
}
