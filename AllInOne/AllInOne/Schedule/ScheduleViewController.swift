//
//  ScheduleViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import Firebase

class ScheduleViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var schedules = [Schedule]()
    
    var scheduleRef: DatabaseReference = Database.database().reference().ref.child("schedule")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Schedule"
        
        let AddBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushToCreatePage))
        navigationItem.rightBarButtonItem = AddBarButtonItem

        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doLogoutAction(_ :)))
        navigationItem.leftBarButtonItem = logoutBarButtonItem

        let nib = UINib(nibName: "ScheduleTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        scheduleRef.observe(.value) { (snapshot: DataSnapshot) in
            
            self.schedules = []
            
            let postDict = snapshot.value as? [String: AnyObject] ?? [:]
            
            for snap in postDict
            {
                let key = snap.key
                let value = snap.value as? [String: AnyObject] ?? [:]
                let schedule = Schedule(key: key, dictionary: value)
                
                self.schedules.insert(schedule, at: 0)
            }
            
            self.tableView.reloadData()
        }
    }
    
    @objc func pushToCreatePage(_ sender: UIBarButtonItem)
    {
        let scheduleAddPage = ScheduleAddViewController()
        
        navigationController?.pushViewController(scheduleAddPage, animated: true)
    }

    @objc func doLogoutAction(_ sender: UIBarButtonItem)
    {
        if Auth.auth().currentUser != nil
        {
            do {
                try Auth.auth().signOut()
                navigationController?.popViewController(animated: true)
            } catch let error as NSError
            {
                print(error.localizedDescription)
            }
        }
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ScheduleTableViewCell else {
            fatalError("Can't dequeue cell")
        }
        
        let schedule = schedules[indexPath.row]
        
        cell.titleLabel?.text = schedule.scheduleTitle
        cell.descriptionLabel?.text = schedule.scheduleDescription
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let schedule = schedules[indexPath.row]
            let theRef = scheduleRef.child(schedule.scheduleKey)
            theRef.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
