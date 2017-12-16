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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "gonext" {
            let vc = segue.destination as! DetailViewController
            vc.str = "hello"
        }
    }
    
    @IBAction func unwind(for segue: UIStoryboardSegue)
    {
        if segue.identifier == "unwind_vc"{
            let vc = segue.source as! DetailViewController
            if let str = vc.str{
                print(str)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

