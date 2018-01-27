//
//  APPViewController.swift
//  PageViewDemo
//
//  Created by KuanWei on 2018/4/4.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

class APPViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.view.frame = view.bounds

        let initVC = viewControllerAtIndex(index: 0)
        let viewControllers: [UIViewController] = [initVC]
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)

        self.addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
    }

    func viewControllerAtIndex(index: Int) -> UIViewController {

        let childVC: APPChildViewController = APPChildViewController()
        childVC.index = index

        return childVC
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        let childVC = viewController as! APPChildViewController

        var index = childVC.index

        if index == 0 {
            return nil
        }

        index-=1

        return viewControllerAtIndex(index: index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let childVC = viewController as! APPChildViewController

        var index = childVC.index

        index+=1

        if index == 5 {
            return nil
        }

        return viewControllerAtIndex(index: index)
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 5
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
