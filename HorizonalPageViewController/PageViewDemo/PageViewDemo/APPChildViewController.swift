//
//  APPChildViewController.swift
//  PageViewDemo
//
//  Created by KuanWei on 2018/4/4.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

class APPChildViewController: UIViewController {

    var index: Int = 0
    @IBOutlet weak var screenNumberLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        screenNumberLabel.text = "screen #\(index)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
