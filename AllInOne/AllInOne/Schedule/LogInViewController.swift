//
//  LogInViewController.swift
//  AllInOne
//
//  Created by KuanWei on 2018/1/8.
//  Copyright © 2018年 cracktheterm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        navigationItem.title = "Log In"

        if Auth.auth().currentUser != nil
        {
            let scheduleVC = ScheduleViewController()
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func doLogInAction(_ sender: UIButton)
    {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in

            if error == nil
            {
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
        }
    }

    @IBAction func doResetPasswordAction(_ sender: UIButton)
    {
        let resetPasswordVC = ResetPasswordViewController()
        navigationController?.pushViewController(resetPasswordVC, animated: true)
    }
}
