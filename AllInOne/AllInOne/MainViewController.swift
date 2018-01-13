//
//  MainViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        loadTabs()
    }

    func loadTabs()
    {
        let dict1 = ["title" : "Home", "className" : "HomeViewController", "image" : "tabbar-icon-home", "includeNavigation" : "true"]
        let dict2 = ["title" : "Map", "className" : "MapViewController", "image" : "tabbar-icon-family", "includeNavigation" : "true"]
        let dict3 = ["title" : "Schedule", "className" : "LogInViewController", "image" : "tabbar-icon-schedule", "includeNavigation" : "true"]
        let dict4 = ["title" : "Settings", "className" : "SettingsViewController", "image" : "tabbar-icon-settings", "includeNavigation" : "true"]
        
        let tabs: Array = [dict1, dict2, dict3, dict4];
        
        var viewControllers = [UIViewController]();
        
        for tabConfig in tabs
        {
            let title = tabConfig["title"];
            let imageName = tabConfig["image"];
            let className = tabConfig["className"];
            let includeNavigation = tabConfig["includeNavigation"];
            
            if (className?.count == 0)
            {
                continue;
            }
            
            let myclass = stringClassFromString(className!) as! UIViewController.Type
            var target = myclass.init()
            
            if includeNavigation == "true" {
                let navi = UINavigationController(rootViewController: target);
                target = navi;
            }
            
            let image = UIImage(named: imageName!);
            
            target.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: image);
            
            viewControllers.append(target);
        }
        
//        let itemSelectTintColor = UIColor(red: 0.1647, green: 0.6392, blue: 0.5529, alpha: 1.0)
//        UITabBar.appearance().tintColor = itemSelectTintColor;
        
        self.viewControllers = viewControllers;
    }
    
    func stringClassFromString(_ className: String) -> AnyClass!
    {
        /// get namespace
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;
        
        /// get 'anyClass' with classname and namespace
        let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!;
        
        // return AnyClass!
        return cls;
    }
}
