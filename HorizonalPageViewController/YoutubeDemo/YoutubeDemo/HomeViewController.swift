//
//  HomeViewController.swift
//  YoutubeDemo
//
//  Created by KuanWei on 2018/4/3.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuBarView: UIView!

    lazy var menuBarVC: MenuBarViewController = {
        let menuBar = MenuBarViewController()
        menuBar.homeVC = self
        return menuBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false

        self.automaticallyAdjustsScrollViewInsets = false;

        navigationItem.title = "Home"
        setupMenuBar()
        setupCollectionView()
        setupNavBarButtons()
    }

    func setupNavBarButtons() {
//        let searchImage = UIImage(named: "search_icon")?.withRenderingMode(.alwaysOriginal)
//        let searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleSearch))
//
//        let moreButton = UIBarButtonItem(image: UIImage(named: "nav_more_icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))

        let searchBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearch))

        navigationItem.rightBarButtonItems = [searchBarButtonItem]
    }

    @objc func handleSearch() {
        print("handleSearch")
        scrollToMenuIndex(menuIndex: 2)
    }

    @objc func handleMore() {
        print("handleMore")
    }

    func setupMenuBar() {
//        menuBarView.addSubview(menuBarVC.view)
    }

    func setupCollectionView() {

        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }

        collectionView?.backgroundColor = UIColor.black

        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)

        collectionView?.isPagingEnabled = true
    }

    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        let colors: [UIColor] = [.blue, .green, UIColor.gray, .purple]

        cell.backgroundColor = colors[indexPath.item]

        print("index = \(indexPath.item)")

        let firstVC = FirstTableViewController()
        firstVC.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(firstVC.view)
        self.addChildViewController(firstVC)

        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
