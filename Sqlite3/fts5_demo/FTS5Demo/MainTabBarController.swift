//
//  MainTabBarController.swift
//  FTS5Demo
//
//  Created by user on 1/19/25.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
    }

    private func configureViews() {
        let firstVC = UINavigationController(rootViewController: FTS5ContentlessTableViewController())
        let secondVC = UINavigationController(rootViewController: SimpleTableViewController())

        firstVC.tabBarItem = UITabBarItem(
            title: "Contentless FTS5",
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        secondVC.tabBarItem = UITabBarItem(
            title: "Default FTS5",
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        viewControllers = [firstVC, secondVC]
    }
}
