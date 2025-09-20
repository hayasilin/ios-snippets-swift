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
        //let simpleVC = UINavigationController(rootViewController: SimpleTableViewController(ftsTable: .defaultTable))

        let firstVC = UINavigationController(rootViewController: FTS5DefaultTableViewController(ftsTable: .fts5DefaultTable))
        let secondVC = UINavigationController(rootViewController: FTS5ContentlessTableViewController(ftsTable: .fts5ContentlessTable))
        let thirdVC = UINavigationController(rootViewController: FTS5ContentlessDeleteTableViewController(ftsTable: .fts5ContentlessDeleteTable))
        let forthVC = UINavigationController(rootViewController: FTS4ContentlessTableViewController())

        firstVC.tabBarItem = UITabBarItem(
            title: FTSTable.fts5DefaultTable.title,
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        secondVC.tabBarItem = UITabBarItem(
            title: FTSTable.fts5ContentlessTable.title,
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        thirdVC.tabBarItem = UITabBarItem(
            title: FTSTable.fts5ContentlessDeleteTable.title,
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        forthVC.tabBarItem = UITabBarItem(
            title: FTSTable.fts4ContentlessTable.title,
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        viewControllers = [firstVC, secondVC, thirdVC, forthVC]
    }
}
