//
//  MainTabBarController.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    private func configureViews() {
        let firstVC = UINavigationController(rootViewController: CollectionDiffableDataSourceViewController())
        let secondVC = UINavigationController(rootViewController: TableDiffableDataSourceViewController())
        let thirdVC = UINavigationController(rootViewController: ChatTableViewController(viewModel: ChatTableViewModel()))
        let fourthVC = UINavigationController(rootViewController: ChatCollectionViewController(viewModel: ChatCollectionViewModel()))

        firstVC.tabBarItem = UITabBarItem(
            title: "CollectionView",
            image: UIImage(systemName: "tablecells"),
            selectedImage: UIImage(systemName: "tablecells.fill")
        )

        secondVC.tabBarItem = UITabBarItem(
            title: "TableView",
            image: UIImage(systemName: "list.bullet.clipboard"),
            selectedImage: UIImage(systemName: "list.clipboard.fill")
        )

        thirdVC.tabBarItem = UITabBarItem(
            title: "Chat TableView",
            image: UIImage(systemName: "text.bubble"),
            selectedImage: UIImage(systemName: "text.bubble.fill")
        )

        fourthVC.tabBarItem = UITabBarItem(
            title: "Chat CollectionView",
            image: UIImage(systemName: "captions.bubble"),
            selectedImage: UIImage(systemName: "captions.bubble.fill")
        )

        viewControllers = [firstVC, secondVC, thirdVC, fourthVC]
    }
}
