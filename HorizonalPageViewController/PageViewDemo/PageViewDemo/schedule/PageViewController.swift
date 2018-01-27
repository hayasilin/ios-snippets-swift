//
//  PageViewController.swift
//  Travostyle
//
//  Created by Jeff on 2017/5/9.
//  Copyright © 2017年 Jeff. All rights reserved.
//

import UIKit

protocol PageViewControllerDalegate : NSObjectProtocol {
    func pageViewController(_ pageViewController: UIPageViewController, nowPage: PageType)
}

class PageViewController: UIPageViewController {

    fileprivate var controllers = [UIViewController]()
    
    weak var pageDelegate: PageViewControllerDalegate?
    
    convenience init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil, controllers: [UIViewController]) {
        self.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        self.controllers = controllers
    }
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        delegate = self
        
        disableScroll()
        
        set(page: .fragment)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func set(page: PageType) {
        setViewControllers([controllers[page.rawValue]],
                           direction: .forward,
                           animated: false,
                           completion: nil)
    }
}

// MARK: - private func
extension PageViewController {
    fileprivate func disableScroll() {
        for view in view.subviews {
            if view.isKind(of: UIScrollView.self) {
                (view as! UIScrollView).isScrollEnabled = false
                break
            }
        }
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = controllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard controllers.count > previousIndex else {
            return nil
        }
        
        return controllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = controllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = controllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return controllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers!.first
        let index = controllers.index(of: pageContentViewController!)
        pageDelegate?.pageViewController(pageViewController, nowPage: PageType(rawValue: index!)!)
    }
}
