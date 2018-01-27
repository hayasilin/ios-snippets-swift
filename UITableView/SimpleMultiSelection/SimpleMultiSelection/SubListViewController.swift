//
//  SubListViewController.swift
//  SimpleMultiSelection
//
//  Created by KuanWei on 2018/6/26.
//  Copyright © 2018年 Kuan-Wei. All rights reserved.
//

import UIKit

class SubListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var dataArray = [String]()
    var selectedDataArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        for index in 0...10 {
            dataArray.append(String(index))
        }

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsMultipleSelection = true

        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButtonAction(sender:)))
        navigationItem.rightBarButtonItem = doneBarButtonItem
    }

    @objc func onDoneButtonAction(sender: UIBarButtonItem) {
        for item in selectedDataArray {
            print(item)
        }
    }
}

extension SubListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row]

        if tableView.indexPathsForSelectedRows?.index(of: indexPath) != nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark

        selectedDataArray.append(dataArray[indexPath.row])
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none

        if let index = selectedDataArray.index(of: dataArray[indexPath.row]) {
            selectedDataArray.remove(at: index)
        }
    }
}


