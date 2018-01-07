//
//  FavoriteShopViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/6/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import UIKit
import SDWebImage

class FavoriteShopViewController: UIViewController {

    //Data
    let apiService: APIServiceProtocol = APIService()
    var shops = [Shop]()
    var gidString = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "我的最愛"
        
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editButtonPressed(_:)))
        navigationItem.rightBarButtonItem = editButton

        let nib = UINib(nibName: "ShopListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        loadFavorites()
    }

    func loadFavorites()
    {
        FavoriteManager.shared.loadFavorites()
        if !FavoriteManager.shared.favorites.isEmpty {
            
            gidString = FavoriteManager.shared.favorites.joined(separator: ",")
            
            apiService.fetchFavoriteShopData(gid: gidString, complete: { (success, shops, error) in
                
                if !(shops?.isEmpty)! && !(error != nil)
                {
                    self.shops = shops!
                    
                    self.sortByGid()
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    func sortByGid()
    {
        var newShops = [Shop]()
        
        let gids = gidString.components(separatedBy: ",")
        
        for gid in gids
        {
            let filtered = shops.filter{ $0.gid == gid }
            if filtered.count > 0
            {
                newShops.append(filtered[0])
            }
        }
        
        shops = newShops
    }
    
    @objc func editButtonPressed(_ sender: UIBarButtonItem)
    {
        if tableView.isEditing
        {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
        }
        else
        {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
        }
    }
}

extension FavoriteShopViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ShopListTableViewCell else {
            fatalError("Can't dequeue cell")
        }
        
        configurateCell(cell, indexPath)
        
        return cell
    }
    
    func configurateCell(_ cell: ShopListTableViewCell, _ indexPath: IndexPath)
    {
        let shop = shops[indexPath.row]
        
        let placeholderImage = UIImage(named: "no_image")
        if let urlString = shop.photoUrl {
            cell.shopImageView?.sd_setImage(with: URL(string: urlString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: nil)
        }
        
        cell.shopNameLabel.text = shop.name
        cell.shopAddressLabel.text = shop.address
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let shop = shops[indexPath.row]
        let shopDetailVC = ShopDetailViewController(nibName: "ShopDetailViewController", bundle: nil, shop)
        navigationController?.pushViewController(shopDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            FavoriteManager.shared.removeFavorites(gid: shops[indexPath.row].gid)
            shops.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        if sourceIndexPath == destinationIndexPath { return }
        
        let source = shops[sourceIndexPath.row]
        shops.remove(at: sourceIndexPath.row)
        shops.insert(source, at: destinationIndexPath.row)
        
        FavoriteManager.shared.moveFavorites(sourceIndex: sourceIndexPath.row, destinationIndexPath.row)
    }
    
}
