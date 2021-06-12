//
//  ViewController.swift
//  SplitDemo
//
//  Created by kuanwei on 2021/6/10.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(navigateToSplitVC))
    }

    @objc func navigateToSplitVC() {
        let splitVC = MainSplitViewController()

        let masterVC = MasterViewController()
        let detailVC = DetailViewController()

        splitVC.viewControllers = [
            UINavigationController(rootViewController: masterVC),
            UINavigationController(rootViewController: detailVC)
        ]

        present(splitVC, animated: true, completion: nil)
    }
}
