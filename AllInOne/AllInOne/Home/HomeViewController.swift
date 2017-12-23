//
//  HomeViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
    var list = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isTranslucent = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        list.append("1")
        list.append("2")
        list.append("3")
        
        let nib = UINib(nibName: "HomeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeTableViewCell
        cell.textLabel?.text = list[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
