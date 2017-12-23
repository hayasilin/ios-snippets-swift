//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Kuan-Wei Lin on 12/16/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    var hotArticleList = [HotArticle]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    for item in arrJSON["list"] as! [AnyObject]
                    {
                        let hotArticle = HotArticle.init(author: item["author"] as? String,
                                                         title: item["title"] as? String,
                                                         board_name: item["board_name"] as? String,
                                                         desc: item["desc"] as? String,
                                                         url: item["url"] as? String)
                        
                        self.hotArticleList.append(hotArticle)
                    }
                }
                else
                {
                    print("is not success")
                }
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
