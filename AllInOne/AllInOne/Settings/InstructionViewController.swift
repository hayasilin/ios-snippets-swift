//
//  InstructionViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/24/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import WebKit

class InstructionViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var activityIndicatorView = UIActivityIndicatorView()
    var loadingView = UIView()
    
    let githubUrlString = "https://github.com/hayasilin"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        let url = URL(string: githubUrlString)
        webView.load(URLRequest(url: url!))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func showLoadingIndicator(_ view: UIView)
    {
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = view.center
        loadingView.clipsToBounds = true
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        loadingView.layer.cornerRadius = 10
        
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        activityIndicatorView.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicatorView)
        view.addSubview(loadingView)
        activityIndicatorView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        showLoadingIndicator(view)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        activityIndicatorView.stopAnimating()
        loadingView.isHidden = true
    }
}


