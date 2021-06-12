//
//  DetailViewController.swift
//  SplitDemo
//
//  Created by kuanwei on 2021/6/10.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    var article: HotArticle? {
        didSet {
            refreshUI()
        }
    }

    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        title = "Detail"

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func refreshUI() {
        if let urlString = article?.url, let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
}
