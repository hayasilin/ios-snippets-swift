//
//  TutorialPageViewController.swift
//  PageViewDemo
//
//  Created by KuanWei on 2018/4/3.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController, UIScrollViewDelegate {

    private(set) lazy var allViewControllers = [UIViewController]()

    var menuBar: MenuBarViewController?

    var pageIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        let firstVC = FirstViewController()
        let secondVC = SecondViewController()
        let thirdVC = ThirdViewController()

        allViewControllers.append(firstVC)
        allViewControllers.append(secondVC)
        allViewControllers.append(thirdVC)

        if let firstViewController = allViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }

    func setupMenuBar(menuBar: MenuBarViewController) {
        self.menuBar = menuBar
    }

    func scrollToThePage(index: Int) {
        print("pageIndex = \(pageIndex)")

        if pageIndex == index { return }

        let direction: UIPageViewControllerNavigationDirection!
        if index > pageIndex {
            direction = .forward
        }else{
            direction = .reverse
        }

        self.setViewControllers([allViewControllers[index]], direction: direction, animated: true, completion: nil)

        pageIndex = index
    }

}

extension TutorialPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return allViewControllers.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("didFinishAnimating")
        let pageContentViewController = pageViewController.viewControllers!.first
        pageIndex = allViewControllers.index(of: pageContentViewController!)!
        print("pageIndex = \(String(describing: pageIndex))")

        menuBar?.setupNowPage(currentPage: PageType(rawValue: pageIndex)!)

    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = allViewControllers.index(of: viewController) else {
            return nil
        }

        print("before viewControllerIndex = \(viewControllerIndex)")

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard allViewControllers.count > previousIndex else {
            return nil
        }

        return allViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = allViewControllers.index(of: viewController) else {
            return nil
        }

        print("after viewControllerIndex = \(viewControllerIndex)")

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = allViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return allViewControllers[nextIndex]
    }
}
