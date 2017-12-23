//
//  HomeViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
    var hotArticleList = [HotArticle]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "HomeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        requestDataFromAPI()
    }
    
    func requestDataFromAPI(){
        
        let apiString: String = "http://disp.cc/api/hot_text.json"
        
        let url: URL = URL(string: apiString)!
        
        let requestManager: RestfulRequestManager = RestfulRequestManager()
        
        try? requestManager.get(url: url, completionHandler: { data, response, error in
            
            let responseObj = try? JSONSerialization.jsonObject(with: data!) as! [String : AnyObject]
            
            if let arrJSON = responseObj {
                
                if arrJSON["isSuccess"] as! Int == 1
                {
                    for item in arrJSON["list"] as! [AnyObject]
                    {
                        let hotArticle = HotArticle.init(author: item["author"] as? String,
                                                         title: item["title"] as? String,
                                                         board_name: item["board_name"] as? String,
                                                         desc: item["desc"] as? String,
                                                         url: item["url"] as? String,
                                                         img_list: item["img_list"] as? [String])

                        self.hotArticleList.append(hotArticle)
                    }
                }
                else
                {
                    print("is not success")
                }
            }
            
            let mainQueue = DispatchQueue.main
            mainQueue.async {
                self.tableView.reloadData()
            }
        })
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotArticleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeTableViewCell
        
        let hotArticle: HotArticle = hotArticleList[indexPath.row]
        let imageUrlString = hotArticle.img_list?.first
        let imageUrl = URL(string: imageUrlString!)
        
        cell.titleLabel.text = hotArticle.title
        cell.descLabel.text = hotArticle.desc
        cell.articleImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder.png") , options: SDWebImageOptions(rawValue: 0), completed: nil)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let hotArticle: HotArticle = hotArticleList[indexPath.row]
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil, urlString: hotArticle.url)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
}
