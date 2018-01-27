//
//  MainListViewController.swift
//  SimpleMultiSelection
//
//  Created by KuanWei on 2018/6/26.
//  Copyright © 2018年 Kuan-Wei. All rights reserved.
//

import UIKit

class MainListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var dataArray = [String]()
    var selectedDataArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        for index in 1...10 {
            dataArray.append(String(index))
        }

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButtonAction(sender:)))
        let pushNextBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(onPushNextButtonAction(sender:)))

        navigationItem.rightBarButtonItems = [pushNextBarButtonItem, doneBarButtonItem]
    }

    @objc func onDoneButtonAction(sender: UIBarButtonItem) {
        for item in selectedDataArray {
            print(item)
        }
    }

    @objc func onPushNextButtonAction(sender: UIBarButtonItem) {
        let subListVC = SubListViewController()
        navigationController?.pushViewController(subListVC, animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row]

        if selectedDataArray.contains(dataArray[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedDataArray.index(of: dataArray[indexPath.row]) {
            selectedDataArray.remove(at: index)
        } else {
            selectedDataArray.append(dataArray[indexPath.row])
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }


}
