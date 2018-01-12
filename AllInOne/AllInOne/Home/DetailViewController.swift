//
//  DetailViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    var webView: WKWebView!
    var activityIndicatorView = UIActivityIndicatorView()
    var loadingView = UIView()
    var urlString: String?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, urlString: String?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.urlString = urlString
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        let url = URL(string: urlString!)
        webView.load(URLRequest(url: url!))
        webView.allowsBackForwardNavigationGestures = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showLoadingIndicator(view)
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
}

extension DetailViewController: WKNavigationDelegate
{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print("didStartProvisionalNavigation")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        print("decidePolicyFor navigationAction")
        if navigationAction.navigationType == WKNavigationType.linkActivated
        {
            decisionHandler(WKNavigationActionPolicy.cancel)
        }
        else
        {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void)
    {
        print("decidePolicyFor navigationResponse")

        if !navigationResponse.isForMainFrame
        {
            decisionHandler(WKNavigationResponsePolicy.cancel)
        }
        else
        {
            decisionHandler(WKNavigationResponsePolicy.allow)
        }
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!)
    {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }


    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        print("didFail navigation")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        print("didFinish navigation")

        activityIndicatorView.stopAnimating()
        loadingView.isHidden = true
    }
}






