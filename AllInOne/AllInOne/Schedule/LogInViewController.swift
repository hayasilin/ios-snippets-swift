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
import FBSDKLoginKit

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        navigationItem.title = "Log In"
        navigationItem.setHidesBackButton(true, animated: false)

        if Auth.auth().currentUser != nil
        {
            let scheduleVC = ScheduleViewController()
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
        
        setupFacebookLogin()
    }
    
    func setupFacebookLogin()
    {
        facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        facebookLoginButton.delegate = self
        
        if (FBSDKAccessToken.current()) != nil
        {
            fetchProfile()
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
    
    @IBAction func pushSignUpPage(_ sender: UIButton)
    {
        let singupVC = SignUpViewController()
        navigationController?.pushViewController(singupVC, animated: true)
    }
}

extension LogInViewController: FBSDKLoginButtonDelegate
{
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        fetchProfile()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
    {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool
    {
        return true
    }
    
    func fetchProfile()
    {
        print("attempt to fetch profile......")
        
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: {
            connection, result, error -> Void in
            
            if error != nil
            {
                print("登入失敗")
                print("longinerror =\(String(describing: error?.localizedDescription))")
            }
            else
            {
                
                if let resultNew = result as? [String:Any]
                {
                    print("成功登入")
                    
                    let email = resultNew["email"]  as! String
                    print("email = \(email)")
                    
                    let firstName = resultNew["first_name"] as! String
                    print("firstName = \(firstName)")
                    
                    let lastName = resultNew["last_name"] as! String
                    print("lastName = \(lastName)")
                    
                    if let picture = resultNew["picture"] as? NSDictionary,
                        let data = picture["data"] as? NSDictionary,
                        let url = data["url"] as? String {
                        print("avatar url = \(url)") //臉書大頭貼的url, 再放入imageView內秀出來
                    }
                }
            }
        })
    }
}
