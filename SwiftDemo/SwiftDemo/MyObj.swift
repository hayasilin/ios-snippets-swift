//
//  MyObj.swift
//  SwiftDemo
//
//  Created by Kuan-Wei Lin on 12/16/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit

class MyObj: NSObject {
    
    @objc func receiveNotification(_ notification: NSNotification){
        if let num = notification.object as? NSNumber{
            print("Name: \(notification.name), Value: \(num.intValue)")
        }
    }
}
