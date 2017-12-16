//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Kuan-Wei Lin on 12/16/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let myObj = MyObj()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            myObj,
            selector: #selector(MyObj.receiveNotification(_:)),
            name: NSNotification.Name("MYKEY"),
            object: nil
        )
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        struct Count_Value{
            static var n = 0
        }
        
        Count_Value.n += 1
        let num = NSNumber(value: Count_Value.n)
        
        let noti = Notification(
            name: Notification.Name("MYKEY"),
            object: num,
            userInfo: nil
        )
        
        NotificationCenter.default.post(noti)
    }
    
    
}
