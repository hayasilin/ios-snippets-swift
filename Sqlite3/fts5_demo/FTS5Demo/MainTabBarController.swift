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
        let firstVC = UINavigationController(rootViewController: FTS5ContentlessDeleteTableViewController(ftsTable: .contentlessDeleteTable))
        let secondVC = UINavigationController(rootViewController: FTS5ContentlessTableViewController(ftsTable: .contentlessTable))
//        let thridVC = UINavigationController(rootViewController: SimpleTableViewController(ftsTable: .defaultTable))
        let thridVC = UINavigationController(rootViewController: FTS4ContentlessTableViewController())

        firstVC.tabBarItem = UITabBarItem(
            title: FTSTable.contentlessTable.title,
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        secondVC.tabBarItem = UITabBarItem(
            title: FTSTable.contentlessDeleteTable.title,
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        thridVC.tabBarItem = UITabBarItem(
            title: FTSTable.defaultTable.title,
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        viewControllers = [firstVC, secondVC, thridVC]
    }
}
