//
//  AboutViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/13/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    let informationTitles = ["Version", "Build"]
    var appInfos = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            appInfos.append(version)
        }
        
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        {
            appInfos.append(build)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let reuseCellID = "cell";
        
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseCellID)
        
        if cell == nil
        {
            cell = UITableViewCell(style: .value1, reuseIdentifier: reuseCellID)
        }
        
        cell?.textLabel?.text = informationTitles[indexPath.row]
        cell?.detailTextLabel?.text = appInfos[indexPath.row]
        
        return cell!
    }

    

}
