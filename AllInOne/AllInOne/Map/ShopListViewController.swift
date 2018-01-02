//
//  ShopListViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/1/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import UIKit

class ShopListViewController: UIViewController {

    var tableView: UITableView!
    
    let apiService: APIServiceProtocol = APIService()
    var allShops = [Shop]()
    
    override func loadView()
    {
        super.loadView()
        
        view = UIView(frame: CGRect.zero)
        tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        view.addSubview(tableView)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
//        tableView.backgroundColor = UIColor(red: 38.0/255.0, green: 38.0/255.0, blue: 38.0/255.0, alpha: 1)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        getShopData()
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
    }
    
    func getShopData()
    {
        apiService.fetchShopData { [weak self] (success, shops, error) in
            self?.allShops = shops
            print("allShops = \(String(describing: self?.allShops))")
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension ShopListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allShops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let shop = allShops[indexPath.row]
        
        cell.textLabel?.text = shop.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("indexPath = \(indexPath.row)")
    }
}
