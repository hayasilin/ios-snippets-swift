//
//  MainTabBarController.swift
//  CollectionViewDemo
//
//  Created by user on 4/26/25.
//  Copyright © 2025 Travostyle. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
    }

    private func configureViews() {
        let firstVC = UINavigationController(rootViewController: CollectionViewController())
        let secondVC = UINavigationController(rootViewController: CollectionViewController())

        firstVC.tabBarItem = UITabBarItem(
            title: "Basic",
            image: UIImage(systemName: "tablecells"),
            selectedImage: UIImage(systemName: "tablecells.fill")
        )

        secondVC.tabBarItem = UITabBarItem(
            title: "Advanced",
            image: UIImage(systemName: "tablecells"),
            selectedImage: UIImage(systemName: "tablecells.fill")
        )

        viewControllers = [firstVC, secondVC]
    }
}
