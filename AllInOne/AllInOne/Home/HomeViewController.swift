//
//  HomeViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
    var hotArticleList = [HotArticle]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isTranslucent = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let nib = UINib(nibName: "HomeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        requestDataFromAPI()
    }
    
    func requestDataFromAPI(){
        
        let apiString: String = "http://disp.cc/api/hot_text.json"
        
        let url: URL = URL(string: apiString)!
        
        try? get(url: url, completionHandler: { data, response, error in
            
            let responseObj = try? JSONSerialization.jsonObject(with: data!) as! [String : AnyObject]
            
            if let arrJSON = responseObj {
                
                if arrJSON["isSuccess"] as! Int == 1
                {
                    //Swift 4 way
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let articles = try! decoder.decode(List.self, from: data!)
                    self.hotArticleList = articles.list
                    
                    //Swift 3 way
//                    for item in arrJSON["list"] as! [AnyObject]
//                    {//                        print("item = \(item)")
//                        let hotArticle = HotArticle.init(hotNum: item["hot_num"] as! String,
//                                                         author: item["author"] as! String,
//                                                         title: item["title"] as! String,
//                                                         boardName: item["board_name"] as! String,
//                                                         desc: item["desc"] as! String,
//                                                         url: item["url"] as! String)
//
//                        self.hotArticleList.append(hotArticle)
//                    }
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
    
    // GET METHOD
    func get(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        var request: URLRequest = URLRequest(url: url)
        
        let session: URLSession = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        session.dataTask(with: request, completionHandler: completionHandler).resume()
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
        
        cell.textLabel?.text = hotArticle.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let hotArticle: HotArticle = hotArticleList[indexPath.row]
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil, urlString: hotArticle.url)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
