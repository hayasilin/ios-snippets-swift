//
//  HomeViewController.swift
//  PageViewDemo
//
//  Created by KuanWei on 2018/4/4.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var menuBarView: UIView!
    @IBOutlet weak var pageView: UIView!

    @IBOutlet var barView: UIView!
    
    
    let page = TutorialPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

    var nowPage: PageType = .fragment
    var initPageType = PageType.fragment

    lazy var menuBarVC: MenuBarViewController = {
        let menuBar = MenuBarViewController()
        menuBar.homeVC = self
        return menuBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        print(navigationController!)
        navigationController?.hidesBarsOnSwipe = true
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        navigationController?.navigationBar.isTranslucent = false
        page.view.frame = pageView.bounds
        pageView.addSubview(page.view)

        setupMenuBar()

        let searchBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearch))
        navigationItem.rightBarButtonItem = searchBarButtonItem

        nowPage = initPageType
        page.scrollToThePage(index: nowPage.rawValue)
    }

    func setupMenuBar() {
        menuBarVC.view.frame = menuBarView.bounds
        menuBarView.addSubview(menuBarVC.view)
        page.setupMenuBar(menuBar: menuBarVC)
    }

    @objc func handleSearch() {
        scrollToMenuIndex(menuIndex: 2)
    }

    func scrollToMenuIndex(menuIndex: Int) {
        page.scrollToThePage(index: menuIndex)
        nowPage = PageType(rawValue: menuIndex)!
        menuBarVC.setupNowPage(currentPage: nowPage)
    }

}
