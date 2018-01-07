//
//  SignUpViewController.swift
//  AllInOne
//
//  Created by KuanWei on 2018/1/8.
//  Copyright © 2018年 cracktheterm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        navigationItem.title = "Sign Up"
        navigationController?.navigationBar.isTranslucent = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func doSignUpAction(_ sender: UIButton)
    {
        if emailTextField.text == "" || passwordTextField.text == ""
        {
            let alert = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)

            present(alert, animated: true, completion: nil)
        }
        else
        {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in

                if error == nil
                {
                    print("You have successfully signed up")

                    let scheduleVC = ScheduleViewController()
                    self.navigationController?.pushViewController(scheduleVC, animated: true)
                }
                else
                {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(okAction)

                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func doLogInAction(_ sender: UIButton)
    {
        let loginVC = LogInViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
}
