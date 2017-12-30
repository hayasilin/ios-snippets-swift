//
//  ScheduleAddViewController.swift
//  AllInOne
//
//  Created by KuanWei on 2017/12/28.
//  Copyright © 2017年 cracktheterm. All rights reserved.
//

import UIKit
import Firebase

class ScheduleAddViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var scheduleRef: DatabaseReference = Database.database().reference().ref.child("schedule")
    var createTime: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d H:m:s"
        createTime = formatter.string(from: Date())
        print("now time = \(createTime)")
    }
    
    func saveSchedule()
    {
        let title = titleTextField.text
        let description = descriptionTextField.text
        
        if title != "" && description != "" {
            let newSchedule: Dictionary<String, AnyObject> = [
                "title": title as AnyObject,
                "description": description as AnyObject,
                "create_time": createTime as AnyObject
            ]
            
            createNewSchedule(schedule: newSchedule)
        }
    }
    
    func createNewSchedule(schedule: Dictionary<String, AnyObject>) {
        let firebaseNewSchedule = scheduleRef.childByAutoId()
        firebaseNewSchedule.setValue(schedule)
    }
    
    @IBAction func doSaveAction(_ sender: UIButton)
    {
        saveSchedule()
        
        navigationController?.popViewController(animated: true)
    }

}
