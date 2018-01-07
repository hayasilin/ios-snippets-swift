//
//  ResetPasswordViewController.swift
//  AllInOne
//
//  Created by KuanWei on 2018/1/8.
//  Copyright © 2018年 cracktheterm. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {


    @IBOutlet var emailTextField: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func doResetPasswordAction(_ sender: UIButton) {
    }
    
}
