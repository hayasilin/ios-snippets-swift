//
//  FirstTableViewController.swift
//  YoutubeDemo
//
//  Created by KuanWei on 2018/4/3.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

class FirstTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let dataArray = ["1", "2", "3", "4", "5", "6","7", "8", "9","10", "11", "12", "13", "14", "15", "16","17", "18", "19","20"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false;
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = dataArray[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt = \(indexPath.row)")
    }



}
