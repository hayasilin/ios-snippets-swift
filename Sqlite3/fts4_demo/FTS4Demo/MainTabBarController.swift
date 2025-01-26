//
//  MainTabBarController.swift
//  FTS4Demo
//
//  Created by user on 1/17/25.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
    }

    private func configureViews() {
//        let firstVC = UINavigationController(rootViewController: SimpleTableViewController())
        let firstVC = UINavigationController(rootViewController: FTS4Version1TableViewController())
        let secondVC = UINavigationController(rootViewController: FTS4Version2TableViewController())
        let thirdVC = UINavigationController(rootViewController: FTS4Version3TableViewController())

        firstVC.tabBarItem = UITabBarItem(
            title: "Version 1",
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        secondVC.tabBarItem = UITabBarItem(
            title: "Version 2",
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        thirdVC.tabBarItem = UITabBarItem(
            title: "Version 3",
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        viewControllers = [firstVC, secondVC, thirdVC]
    }
}
