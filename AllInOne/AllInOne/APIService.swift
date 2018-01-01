//
//  APIService.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/1/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import Foundation

protocol APIServiceProtocol {
    func fetchShopData(complete:@escaping(_ success: Bool, _ shops: [Shop], _ error: Error?) ->())
}

class APIService: APIServiceProtocol  {
    
    private let yahooLocalManager = YahooLocalManager()
    
    func fetchShopData(complete: @escaping (Bool, [Shop], Error?) -> ())
    {
        DispatchQueue.global().async {
            
            self.yahooLocalManager.requestShopFromAPI { (success: Bool, shops: [Shop]?, error: Error?) in
                
                complete(true, shops!, nil)
            }
        }
    }
}
