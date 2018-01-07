//
//  YahooLocalManager.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/1/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import Foundation

let apiRequestUrl = "https://map.yahooapis.jp/search/local/V1/localSearch?appid=dj0zaiZpPUhhdVJPbm9hMnVUMSZzPWNvbnN1bWVyc2VjcmV0Jng9ZmE-&device=mobile&group=gid&sort=geo&output=json&gc=01&image=true&lat=35.7020691&lon=139.7753269&dist=3"

enum YahooLocalRequestType {
    case yahooLocationRequestTypeGeneral
    case yahooLocationRequestTypeFavorite
}

class YahooLocalManager {
    
    let requestManager: RestfulRequestManager = RestfulRequestManager.sharedInstance
    private var shops = [Shop]()

    var latitute: Double = 0
    var longitude: Double = 0
    
    var gidString = ""
    var requestString = ""
    
    let appID = "appid=dj0zaiZpPUhhdVJPbm9hMnVUMSZzPWNvbnN1bWVyc2VjcmV0Jng9ZmE-"
    
    init()
    {
        
    }

    func composeRequestString(_ type: YahooLocalRequestType)
    {
        switch type {
        case .yahooLocationRequestTypeGeneral:
            requestString = "https://map.yahooapis.jp/search/local/V1/localSearch?\(appID)&device=mobile&group=gid&sort=geo&results=100&output=json&gc=01&image=true&lat=\(latitute)&lon=\(longitude)&dist=3"
            break
        case .yahooLocationRequestTypeFavorite:
            requestString = "https://map.yahooapis.jp/search/local/V1/localSearch?\(appID)&device=mobile&output=json&gc=01&image=true&gid=\(gidString)"
            break
        }
    }
    
    func getShops() -> [Shop]
    {
        return self.shops
    }
    
    func requestShopFromAPI(complete:@escaping(_ success: Bool, _ shops: [Shop]?, _ error: Error?) ->())
    {
        let url = URL(string: requestString)
        
        try? requestManager.get(url: url!, completionHandler: { (data, urlResponse, error) in
            
            let responseObj = try? JSONSerialization.jsonObject(with: data!) as! [String : AnyObject]
//            print("responseObj = \(String(describing: responseObj))")

            if let arrJSON = responseObj
            {
                if let value = arrJSON["ResultInfo"]
                {
                    let totalCount = value["Total"] as? Int

                    if totalCount != 0 && totalCount != nil
                    {
                        for item in arrJSON["Feature"] as! [AnyObject]
                        {
                            var shop = Shop()
                            shop.gid = item["Gid"] as? String
                            shop.name = item["Name"] as? String
                            
                            let geometry = item["Geometry"] as! [String: String]
                            let coordinates = geometry["Coordinates"]
                            let components = coordinates?.components(separatedBy: ",")
                            shop.lat = Double(components![1])
                            shop.lon = Double(components![0])
                            
                            let property = item["Property"] as! [String: AnyObject]
                            shop.yomi = property["Yomi"] as? String
                            shop.tel = property["Tel1"] as? String
                            shop.address = property["Address"] as? String
                            shop.catchCopy = property["CatchCopy"] as? String
                            shop.photoUrl = property["LeadImage"] as? String
                            
                            if let stations = property["Station"] as? [[String: String]] {
                                var line = ""
                                let lineString = stations[0]
                                let lineName = lineString["Railway"]
                                let lines = lineName?.components(separatedBy: "/")
                                line = lines![0]
                                
                                let stationDict = stations[0]
                                if let stationName = stationDict["Name"] {
                                    shop.station = "\(line) \(stationName)"
                                }
                                else
                                {
                                    shop.station = "\(line)"
                                }
                            }
                            
                            self.shops.append(shop)
                        }
                        
                        complete(true, self.shops, nil)
                    }
                    else
                    {
                        complete(false, nil, error)
                    }
                }
                else
                {
                    complete(false, nil, error)
                }
            }
        })
    }
}
