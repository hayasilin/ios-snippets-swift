//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Kuan-Wei Lin on 12/16/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var list1 = [String]()
    var list2 = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        pickerView.delegate = self
        pickerView.dataSource = self
        
        list1.append("球類")
        list1.append("田徑")
        list1.append("飛行")
        list1.append("體操")
        
        list2.append("棒球")
        list2.append("壘球")
        list2.append("雙槓")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0
        {
            return list1.count
        }
        else
        {
            return list2.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if component == 0
        {
            return list1[row]
        }
        else
        {
            return list2[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if component == 0
        {
            print("List1 Choosen: \(list1[row])")
        }
        else
        {
            print("List2 Choosen: \(list2[row])")
        }
    }
}

