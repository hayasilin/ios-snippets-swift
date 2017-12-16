//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Kuan-Wei Lin on 12/16/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveNotification(_:)),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )
    }
    
    @objc func receiveNotification(_ notification: NSNotification){
        let device = UIDevice.current
        switch device.orientation{
        case .faceUp:
            print("Device is face up")
            break
        case .faceDown:
            print("Device is face down")
            break
        case .portraitUpsideDown:
            print("Device is placed up side down")
            NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
            break
        default:break
        }
    }
    
}
