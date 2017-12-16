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

    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d H:m:s"
        let dateString = formatter.string(from: sender.date)
        
        print(dateString)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

