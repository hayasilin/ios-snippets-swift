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
import FacebookLogin

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
        
        setupFacebookLogin()
    }
    
    func setupFacebookLogin()
    {
        // Add a custom login button to your app
        let myLoginButton = UIButton(type: .custom)
        myLoginButton.backgroundColor = UIColor.darkGray
        myLoginButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
        myLoginButton.center = view.center;
        myLoginButton.setTitle("FB Login", for: .normal)
        
        // Handle clicks on the button
        myLoginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        
        // Add the button to the view
        view.addSubview(myLoginButton)
    }
    
    @objc func loginButtonClicked()
    {
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile, .userFriends], viewController: self) { (loginResult) in
            
            print("loginResult = \(loginResult)")
            switch loginResult{
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("granted = \(grantedPermissions)")
                print("declinedPermissions = \(declinedPermissions)")
                print("accessToken = \(accessToken)")
                print("Logged in!")
            }
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
                self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func pushSignUpPage(_ sender: UIButton)
    {
        let singupVC = SignUpViewController()
        navigationController?.pushViewController(singupVC, animated: true)
    }
    
}
