//
//  SettingsViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var menu: [String: [String]]?
    
    var keys: [String]?
    var items: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Settings"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let path = Bundle.main.path(forResource: "Settings", ofType: "plist")!
        menu = NSDictionary(contentsOfFile: path) as? [String : [String]]
        
        if let dict = menu{
            print(dict)
        }
    }

}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
}
