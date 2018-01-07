//
//  ShopListViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/1/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import UIKit
import SDWebImage

protocol ShopListViewControllerProtocol {

    func didSelectShopAtIndexPath(_ indexPath: IndexPath);
}

class ShopListViewController: UIViewController {

    var delegate: ShopListViewControllerProtocol?

    var tableView: UITableView!
    
    let apiService: APIServiceProtocol = APIService()
    var allShops = [Shop]()

    var shopDictionary = [String : Int]()

    var selectedIndex: Int?

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
        let nib = UINib(nibName: "ShopListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
    }
    
    func getShopData(_ shops: [Shop], completion:@escaping () -> Void)
    {
        self.allShops = shops

        var index = 0
        for shop in allShops
        {
            shopDictionary.updateValue(index, forKey: shop.name!)
            index += 1
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
            completion()
        }
    }

    func selectShopFromListByName(_ shopName: String)
    {
        for (key, value) in shopDictionary
        {
            if key == shopName
            {
                let indexPath = IndexPath(row: value, section: 0)
                selectedIndex = value
                tableView.reloadData()
                tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: false)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ShopListTableViewCell else{
            fatalError("Can not dequeue cell")
        }
        
        configurateCell(cell, indexPath)

        return cell
    }

    func configurateCell(_ cell: ShopListTableViewCell, _ indexPath: IndexPath)
    {
        let shop = allShops[indexPath.row]

        let placeholderImage = UIImage(named: "no_image")
        if let urlString = shop.photoUrl {
            cell.shopImageView?.sd_setImage(with: URL(string: urlString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: nil)
        }

        cell.shopNameLabel.text = shop.name
        cell.shopAddressLabel.text = shop.address
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        delegate?.didSelectShopAtIndexPath(indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.contentView.backgroundColor = UIColor.white
        if indexPath.row == selectedIndex
        {
            cell.contentView.backgroundColor = UIColor.groupTableViewBackground
        }
    }
}
