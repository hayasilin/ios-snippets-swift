//
//  BaseViewController.swift
//
//
//  Created by Jeff.
//  Copyright © 2017年 Jeff. All rights reserved.
//  test

import UIKit
import CoreLocation

struct TravostyleNotification {
    
    struct LocationService {
        static let didChangeLocationServiceAuthorization = "DidChangeLocationServiceAuthorization"
        static let didUpdateLocations = "DidUpdateLocations"
    }
    
    struct Reachability {
        static let isReachableViaWiFi = "IsReachableViaWiFi"
        static let isReachableViaCellular = "IsReachableViaCellular"
        static let isNotReachable = "IsNotReachable"
    }
    
    struct FragmentViewController {
        static let reloadData = "reloadData"
    }
}

class BaseViewController: UIViewController {

    // MARK:- Public variable
    
    // MARK: - Private variable

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        setNavigationBar()
        prepareForView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = statusBarStyle()
        
        navigationController?.setNavigationBarHidden(isHideNavigationBar(), animated: true)

//        titleView.titleTuple = navigationBarType()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUI()
        
//        if Travostyle.appDelegate.reachability.currentReachabilityStatus == .notReachable {
//            showErrorTopBar()
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    // MARK: - override function
    open func prepareForView() {
        
    }
    
    open func setUI() {
        
    }
    
    open func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
//                keyBoardHeight = keyboardSize.height
            }
        }
    }
    
    open func keyboardWillHide(notification: Notification) {
//        keyBoardHeight = 0
    }
    
    open func applicationDidBecomeActive(notification: Notification) {
        
    }
    
    open func didChangeLocationServiceAuthorization(notification: Notification) {
        
    }
    
    open func didUpdateLocations(notification: Notification) {
        
    }
    
    open func isReachableViaWiFi(notification: Notification) {
//        hideErrorTopBar()
    }
    
    open func isReachableViaCellular(notification: Notification) {
//        hideErrorTopBar()
    }
    
    open func isNotReachable(notification: Notification) {
//        showErrorTopBar()
    }
    
    open func navigationBarType() -> (title: String, desc: String?, showButton: Bool?) {
        return ("", nil, false)
    }
    
    open func isHideNavigationBar() -> Bool {
        return false
    }
    
    open func statusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    open func isStatusBarHidden() -> Bool {
        return false
    }
    
    open func backButtonItem() -> UIBarButtonItem? {
        return UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: nil, action: nil)
    }

    open func leftBarButtonItems() -> [UIBarButtonItem]? {
        return nil
    }
    
    open func rightBarButtonItems() -> [UIBarButtonItem]? {
        return nil
    }

    open func pressTitleButton() {
        
    }
}

// MARK: - private func
extension BaseViewController {
    // MARK: - fileprivate function
    fileprivate func setNavigationBar() {
//        setRightButtonItems()
//        setBackButtonItem()
//        setLeftButtonItems()
        //move title to left bar button
        //navigationItem.titleView = titleView
        
//        titleView.pressLeftBtn { [weak self] in
//            self?.pressTitleButton()
//        }
    }
    
//    fileprivate func setBackButtonItem() {
//        let backBtn = UIButton(type: .custom)
//        backBtn.setImage(UIImage(named: "ic_back"), for: .normal)
//        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
//        let backBarButtonItem = UIBarButtonItem(customView:backBtn)
//        backBtn.rx.tap.subscribe(onNext: { [weak self] in
//            if self?.parent?.childViewControllers.first == self {
//                self?.navigationController?.dismiss(animated: true, completion: nil)
//            } else {
//                self?.navigationController?.popViewController(animated: true)
//            }
//        }).disposed(by: disposeBag)
//
//        let titleItem = UIBarButtonItem(customView:titleView)
//
//        navigationItem.leftBarButtonItems = [backBarButtonItem,titleItem]
//    }
//
//    fileprivate func setLeftButtonItems() {
//        if var leftButtons = leftBarButtonItems() {
//            let titleItem = UIBarButtonItem(customView:titleView)
//            leftButtons.append(titleItem)
//            navigationItem.leftBarButtonItems = leftButtons
//        }
//    }
//
//    fileprivate func setRightButtonItems() {
//        if let rightButtons = rightBarButtonItems() {
//            navigationItem.rightBarButtonItems = rightButtons
//        }
//    }
//
//    fileprivate func showErrorTopBar() {
//        Travostyle.appDelegate.showErrorTopBar()
//        if let navigationController = navigationController {
//            UIView.animate(withDuration: 0.3) {
//                if navigationController.view.y == 0 {
//                    navigationController.view.y = 40
//                }
//                if navigationController.view.height == UIScreen.height() {
//                    navigationController.view.height = navigationController.view.height - 40
//                }
//            }
//        } else {
//            UIView.animate(withDuration: 0.3) {
//                if self.view.y == 0 {
//                    self.view.y = 40
//                }
//                if self.view.height == UIScreen.height() {
//                    self.view.height = self.view.height - 40
//                }
//            }
//        }
//    }
//
//    fileprivate func hideErrorTopBar() {
//        Travostyle.appDelegate.hideErrorTopBar()
//        if let navigationController = navigationController {
//            UIView.animate(withDuration: 0.3) {
//                navigationController.view.y = 0
//                if navigationController.view.height != UIScreen.height() {
//                    navigationController.view.height = navigationController.view.height + 40
//                }
//            }
//        } else {
//            UIView.animate(withDuration: 0.3) {
//                self.view.y = 0
//                if self.view.height != UIScreen.height() {
//                    self.view.height = self.view.height + 40
//                }
//            }
//        }
//    }
}

// MARK: - Public Function
extension BaseViewController {
    func hideKeyBoard() {
        self.view.endEditing(true)
    }
    
//    func presentEditViewController(_ viewController:BaseEditViewController){
//        viewController.fakeBackgroundImage = self.navigationController?.captureScreen()
//        let destViewController = BaseNavigationController(navigationBarClass: BaseNavigationBar.self, rootViewController: viewController)
//        self.navigationController?.present(destViewController, animated: true, completion:nil)
//    }
}

// MARK: - UIGestureRecognizerDelegate
extension BaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


// MARK: - UIPopoverPresentationControllerDelegate
extension BaseViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
