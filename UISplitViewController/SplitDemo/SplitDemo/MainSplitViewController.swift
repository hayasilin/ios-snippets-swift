//
//  MainSplitViewController.swift
//  SplitDemo
//
//  Created by kuanwei on 2021/6/10.
//

import UIKit

class MainSplitViewController: UISplitViewController {

    lazy var masterViewController: UINavigationController = {
        return UINavigationController()
    }()

    lazy var detailViewController: UINavigationController = {
        return UINavigationController()
    }()

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        preferredDisplayMode = .oneBesideSecondary

        presentsWithGesture = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        let master = MasterViewController()
        let detail = DetailListViewController()

        detail.navigationItem.leftItemsSupplementBackButton = true
        detail.navigationItem.leftBarButtonItem = displayModeButtonItem

        master.delegate = detail

        masterViewController.viewControllers = [master]
        detailViewController.viewControllers = [detail]
        
        self.viewControllers = [
            masterViewController,
            detailViewController
        ]
    }
}

// https://xcanoe.top/post/%E4%BD%BF%E7%94%A8%20UISplitViewController%20%E4%BC%98%E5%8C%96%E5%A4%A7%E5%B1%8F%E5%88%86%E6%A0%8F%E5%BC%8F%E4%BD%93%E9%AA%8C/
extension MainSplitViewController: UISplitViewControllerDelegate {
    // 返回true的話要自己定義主視圖的顯示，返回false的話則交給系統自行決定主視圖的顯示
    func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
        return false
    }

    // 返回true的話要自己定二級視圖的顯示，返回false的話則交給系統自行決定二級視圖的顯示
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        return false
    }

    // 當device從regular轉移到compact時會調用這個callback，並要求提供在轉換後要顯示的UIViewController，返回的UIViewController將成為新的primaryViewController，返回nil的話就是默認直接將原本的primary返回
    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        return masterViewController
    }

    // 當device從compact轉移到regular時會調用這個callback，並要求提供在轉換後要顯示的UIViewController，返回的UIViewController將成為新的primaryViewController，返回nil的話就是默認直接將原本的primary返回
    func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        return detailViewController
    }

    // 當device從regular轉移到compact時會調用這個callback，返回false會執行系統默認的摺疊操作，默認會用primaryViewController 的collapseSecondaryViewController(_:for:) 方法，然後移除secondaryViewController
    // 如果返回true則代表要執行自己的操作，系統不會做其他處理，之後會移除secondaryViewController
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let primary = primaryViewController as? UINavigationController,
              let secondary = secondaryViewController as? UINavigationController else {
            return false
        }

        if let viewControllers = secondary.popToRootViewController(animated: false) {
            primary.viewControllers.append(contentsOf: viewControllers)
        }

        return true
    }

    // 當device從compact轉移到regular時會調用這個callback，返回nil會執行系統默認的摺疊操作，默認會用primaryViewController 的 separateSecondaryViewController(for:) 方法
    // 如果返回自己操作的的UIViewController，就會變成新的secondaryViewController
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        return detailViewController
    }
}
