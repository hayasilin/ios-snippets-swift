//
//  ScheduleViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ScheduleViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var schedules = [Schedule]()
    
    var scheduleRef: DatabaseReference = Database.database().reference().ref.child("schedule")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Comments"
        
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushToCreatePage))
        let editBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(doEditAction(_:)))
        navigationItem.rightBarButtonItems = [addBarButtonItem, editBarButtonItem]

        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doLogoutAction(_ :)))
        navigationItem.leftBarButtonItem = logoutBarButtonItem

        let nib = UINib(nibName: "ShopCommentTableViewCell", bundle: nil)
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        checkLoginStatus()
    }
    
    func checkLoginStatus()
    {
        if Auth.auth().currentUser == nil && FBSDKAccessToken.current() == nil
        {
            let LoginVC = LogInViewController()
            navigationController?.pushViewController(LoginVC, animated: true)
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
                
                self.navigationController?.popViewController(animated: true)
            } catch let error as NSError
            {
                print(error.localizedDescription)
            }
        }
        
        if FBSDKAccessToken.current() != nil
        {
            FBSDKLoginManager().logOut()
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func doEditAction(_ sender: UIBarButtonItem)
    {
        if tableView.isEditing
        {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
        }
        else
        {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ShopCommentTableViewCell else {
            fatalError("Can't dequeue cell")
        }
        
        let schedule = schedules[indexPath.row]
        
        cell.titleLabel?.text = schedule.scheduleTitle
        cell.commentLabel?.text = schedule.scheduleDescription
        cell.shopNameLabel.text = schedule.shopName
        
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
        return 100
    }
}
