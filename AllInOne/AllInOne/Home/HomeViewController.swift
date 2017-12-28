//
//  HomeViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import Reachability

class HomeViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
    var hotArticleList = [HotArticle]()
    
    let requestManager: RestfulRequestManager = RestfulRequestManager.sharedInstance
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "HomeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(requestDataFromAPI), for: .valueChanged)
        
        requestDataFromAPI()
        
        //declare this property where it won't go out of scope relative to your listener
        let reachability = Reachability()!
        
        //declare this inside of viewWillAppear
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            print("Network not reachable")
            let alert = UIAlertController(title: "沒有網路連線", message: "請檢察網路連線喲", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func requestDataFromAPI()
    {
        let apiString: String = "http://disp.cc/api/hot_text.json"
        
        let url: URL = URL(string: apiString)!
        
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
                    let alert = UIAlertController(title: "喔喔！", message: "資料取得失敗，請往下滑再試一次", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            let mainQueue = DispatchQueue.main
            mainQueue.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HomeTableViewCell else{
            fatalError("Could not dequeue a cell")
        }
        
        let hotArticle: HotArticle = hotArticleList[indexPath.row]
        cell.update(with: hotArticle)
        
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
