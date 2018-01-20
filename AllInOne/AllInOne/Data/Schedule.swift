//
//  Schedule.swift
//  AllInOne
//
//  Created by KuanWei on 2017/12/28.
//  Copyright © 2017年 cracktheterm. All rights reserved.
//

import Foundation

class Schedule {
    
    private var _scheduleKey: String!
    private var _scheduleTitle: String!
    private var _scheduleDescription: String!
    private var _shopName: String!
    
    var scheduleKey: String {
        return _scheduleKey
    }
    
    var scheduleTitle: String {
        return _scheduleTitle
    }
    
    var scheduleDescription: String {
        return _scheduleDescription
    }
    
    var shopName: String {
        return _shopName
    }
    
    init(key: String, dictionary: Dictionary<String, AnyObject>)
    {
        self._scheduleKey = key
        
        if let title = dictionary["title"] as? String {
            self._scheduleTitle = title
        }
        
        if let description = dictionary["description"] as? String {
            self._scheduleDescription = description
        }
        
        if let shopName = dictionary["shop_name"] as? String {
            self._shopName = shopName
        }
    }
}
