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

        viewControllers = [firstVC, secondVC]
    }
}
