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
            image: nil,
            selectedImage: nil
        )

        secondVC.tabBarItem = UITabBarItem(
            title: "Second",
            image: nil,
            selectedImage: nil
        )

        viewControllers = [firstVC, secondVC]
    }
}
