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
    
    @IBAction func showAlert(_ sender: UIButton)
    {
        let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: {
                print("Alert is closed")
            })
        }
        
        alertController.addAction(okAction)
        show(alertController, sender: self)
    }
    
    @IBAction func showActionSheet(_ sender: UIButton)
    {
        let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: {
                print("Alert is closed")
            })
        }
        
        alertController.addAction(okAction)
        show(alertController, sender: self)
    }
    
    
    @IBAction func showAlertWithTextField(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "Login", message: "Please input username and password", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: {
                print("Alert is closed")
            })
        }
        
        let loginAction = UIAlertAction(title: "Login", style: .default) { (action) in
            let uid = alert.textFields![0].text
            let pwd = alert.textFields![1].text
            
            print("username: \(uid ?? "noValue")")
            print("password: \(String(describing: pwd))")
        }
        
        alert.addTextField { (textfField) in
            textfField.placeholder = "Login"
            alert.addTextField(configurationHandler: { (textField) in
                textfField.placeholder = "password"
                textField.isSecureTextEntry = true
            })
        }
        
        alert.addAction(cancelAction)
        alert.addAction(loginAction)
        
        show(alert, sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

