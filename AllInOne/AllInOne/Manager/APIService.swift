//
//  APIService.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/1/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import Foundation

protocol APIServiceProtocol {
    func fetchShopData(_ latitude: Double, _ longitude: Double, complete:@escaping(_ success: Bool, _ shops: [Shop]?, _ error: Error?) ->())
    
    func fetchFavoriteShopData(gid: String, complete:@escaping(_ success: Bool, _ shops: [Shop]?, _ error: Error?) ->())
}

class APIService: APIServiceProtocol  {
    
    func fetchShopData(_ latitude: Double, _ longitude: Double, complete: @escaping (Bool, [Shop]?, Error?) -> ())
    {
        DispatchQueue.global().async {

            let yahooLocalManager = YahooLocalManager()
            yahooLocalManager.latitute = latitude
            yahooLocalManager.longitude = longitude
            yahooLocalManager.composeRequestString(YahooLocalRequestType.yahooLocationRequestTypeGeneral)
            yahooLocalManager.requestShopFromAPI { (success: Bool, shops: [Shop]?, error: Error?) in
                
                complete(true, shops, nil)
            }
        }
    }
    
    func fetchFavoriteShopData(gid: String, complete: @escaping (Bool, [Shop]?, Error?) -> ())
    {
        DispatchQueue.global().async {
            
            let yahooLocalManager = YahooLocalManager()
            yahooLocalManager.gidString = gid
            yahooLocalManager.composeRequestString(YahooLocalRequestType.yahooLocationRequestTypeFavorite)
            yahooLocalManager.requestShopFromAPI { (success: Bool, shops: [Shop]?, error: Error?) in
                
                complete(true, shops, nil)
            }
        }
    }
}
