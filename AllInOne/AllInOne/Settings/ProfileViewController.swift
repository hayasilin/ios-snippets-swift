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
    
    let profileTitles = ["UserID", "E-mail", "Display Name"]
    var profileData = [String]()
    
    var activityIndicatorView = UIActivityIndicatorView()
    var loadingView = UIView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        checkLoginStatus()
    }
    
    func checkLoginStatus()
    {
        if Auth.auth().currentUser != nil
        {
            print("User is signed in")
            profileData.removeAll()
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
                    profileData.append("您還未設定名稱")
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
        let alert = UIAlertController(title: "喔喔！", message: "您還沒登入喔，請至評論頁登入", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "去登入", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoadingIndicator(_ view: UIView)
    {
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = view.center
        loadingView.clipsToBounds = true
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        loadingView.layer.cornerRadius = 10
        
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        activityIndicatorView.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicatorView)
        view.addSubview(loadingView)
        activityIndicatorView.startAnimating()
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
        
        configurateCell(cell!, indexPath)
        
        return cell!
    }
    
    func configurateCell(_ cell: UITableViewCell, _ indexPath: IndexPath)
    {
        cell.textLabel?.text = profileTitles[indexPath.row]
        cell.detailTextLabel?.text = profileData[indexPath.row]
        
        cell.selectionStyle = .none
        
        if profileTitles[indexPath.row] == "Display Name"
        {
            cell.accessoryType = .detailButton
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        checkChosenCell(cellTitle: (cell?.textLabel?.text)!)
    }
    
    func checkChosenCell(cellTitle: String)
    {
        if cellTitle == "Display Name"
        {
            let alert = UIAlertController(title: "設定顯示名稱", message: "請輸入您要設定的顯示名稱", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: {
                    print("Alert is closed")
                })
            }
            
            let updaeDisplayNameAction = UIAlertAction(title: "更新", style: .default) { (action) in
                let displayName = alert.textFields![0].text
                self.updateUserDisplayName(displayName: displayName!)
                self.showLoadingIndicator(self.view)
            }
            
            alert.addTextField { (textfField) in
                textfField.placeholder = "請輸入顯示名稱"
            }
            
            alert.addAction(cancelAction)
            alert.addAction(updaeDisplayNameAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func updateUserDisplayName(displayName name: String)
    {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges(completion: { (error) in
            
            if (error != nil)
            {
                print("error = \(String(describing: error?.localizedDescription))")
            }
            else
            {
                print("success")
                self.checkLoginStatus()
                self.activityIndicatorView.stopAnimating()
                self.loadingView.isHidden = true
            }
        })
    }
}










