//
//  MainListViewController.swift
//  DynamicCellDemo
//
//  Created by KuanWei on 2018/7/6.
//  Copyright © 2018年 Kuan-Wei. All rights reserved.
//

import UIKit

class MainListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var dataArray = [
        "1",
        "2",
        "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.",
        "In this self-sizing table view cells tutorial, you’ll learn how to create and dynamically size table view cells to fit their contents. You might be thinking, “That’s going to take a lot of work…!”",
        "f you’ve ever created custom table view cells before, chances are good that you have spent a lot of time sizing table view cells in code. You may even be familiar with having to manually calculate the height of every label, image view, text field, and everything else within the cell."
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: String(describing: MainTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: MainTableViewCell.self))

        let photoNib = UINib(nibName: String(describing: ImageTableViewCell.self), bundle: nil)
        tableView.register(photoNib, forCellReuseIdentifier: String(describing: ImageTableViewCell.self))

        let textNib = UINib(nibName: String(describing: TextViewTableViewCell.self), bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: String(describing: TextViewTableViewCell.self))

        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.rowHeight = 44
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MainListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 || indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageTableViewCell.self), for: indexPath) as! ImageTableViewCell
            cell.photoImageView.image = UIImage(named: dataArray[indexPath.row])
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TextViewTableViewCell.self), for: indexPath) as! TextViewTableViewCell
            cell.textView.text = dataArray[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainTableViewCell.self), for: indexPath) as! MainTableViewCell
            cell.mainLabel.text = dataArray[indexPath.row]
            return cell
        }


    }
}
