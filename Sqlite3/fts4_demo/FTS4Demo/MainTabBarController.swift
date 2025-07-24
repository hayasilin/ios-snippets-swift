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
        let firstVC = UINavigationController(rootViewController: FTS4DefaultTableViewController(ftsTable: .defaultTable))
//        let firstVC = UINavigationController(rootViewController: FTS4ExternalContentTableViewController(ftsTable: .externalContentTable))
//        let firstVC = UINavigationController(rootViewController: FTS4Version1TableViewController())
//        let secondVC = UINavigationController(rootViewController: FTS4Version2TableViewController())
//        let thirdVC = UINavigationController(rootViewController: FTS4Version3TableViewController())
//        let forthVC = UINavigationController(rootViewController: FTS4ContentlessTableViewController())

//        firstVC.tabBarItem = UITabBarItem(
//            title: "Simple",
//            image: UIImage(systemName: "list.bullet.rectangle"),
//            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
//        )
//
//        secondVC.tabBarItem = UITabBarItem(
//            title: "Use rowid",
//            image: UIImage(systemName: "list.bullet.rectangle"),
//            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
//        )
//
//        thirdVC.tabBarItem = UITabBarItem(
//            title: "Use interface",
//            image: UIImage(systemName: "list.bullet.rectangle"),
//            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
//        )
//
//        forthVC.tabBarItem = UITabBarItem(
//            title: "Contentless table",
//            image: UIImage(systemName: "list.bullet.rectangle"),
//            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
//        )

//        viewControllers = [firstVC, secondVC, thirdVC, forthVC]
        viewControllers = [firstVC]
    }
}
