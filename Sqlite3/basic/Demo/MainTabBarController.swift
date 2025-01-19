//
//  MainTabBarController.swift
//  Demo
//
//  Created by user on 2024/03/04.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
    }

    private func configureViews() {
        let firstVC = UINavigationController(rootViewController: SimpleTableViewController())
        let secondVC = UINavigationController(rootViewController: SimpleCollectionViewController())

        firstVC.tabBarItem = UITabBarItem(
            title: "First",
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        secondVC.tabBarItem = UITabBarItem(
            title: "Second",
            image: UIImage(systemName: "tablecells"),
            selectedImage: UIImage(systemName: "tablecells.fill")
        )

        viewControllers = [firstVC, secondVC]
    }
}
