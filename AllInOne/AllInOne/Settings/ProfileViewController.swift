//
//  ProfileViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/13/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let profileTitles = ["UserID", "E-mail", "Name"]
    var profileData = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        checkLoginStatus()
    }
    
    func checkLoginStatus()
    {
        if Auth.auth().currentUser != nil
        {
            print("User is signed in")
            let user = Auth.auth().currentUser
            if let user = user
            {
                profileData.append(user.uid)
                profileData.append(user.email!)
                if let name = user.displayName
                {
                    profileData.append(name)
                }
                else
                {
                    profileData.append("")
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else
        {
            print("No user is signed")
            showExecptionAlert()
        }
    }
    
    func showExecptionAlert()
    {
        let alert = UIAlertController(title: "喔喔！", message: "您還沒登入喔，請先登入", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "去登入", style: .default) { (action) in
            let loginVC = LogInViewController()
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return profileData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let reuseCellID = "cell";
        
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseCellID)
        
        if cell == nil
        {
            cell = UITableViewCell(style: .value1, reuseIdentifier: reuseCellID)
        }
        
        cell?.textLabel?.text = profileTitles[indexPath.row]
        cell?.detailTextLabel?.text = profileData[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
}










