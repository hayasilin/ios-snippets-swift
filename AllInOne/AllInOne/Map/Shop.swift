//
//  Shop.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/31/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import Foundation

public struct Shop: CustomStringConvertible
{
    public var gid: String? = nil
    public var name: String? = nil
    public var photoUrl: String? = nil
    public var yomi: String? = nil
    public var tel: String? = nil
    public var address: String? = nil
    public var lat: Double? = nil
    public var lon: Double? = nil
    public var catchCopy: String? = nil
    public var hasCoupon = false
    public var station: String? = nil
    
    public var url: String? {
        get {
            if let gid = gid {
                return "http://loco.yahoo.co.jp/place/g-\(gid)/"
            }
            return nil
        }
    }
    
    public var description: String {
        get {
            var string = "\nGid: \(String(describing: gid))\n"
            string += "Name: \(String(describing: name))\n"
            string += "PhotoUrl: \(String(describing: photoUrl))\n"
            string += "Yomi: \(String(describing: yomi))\n"
            string += "Tel: \(String(describing: tel))\n"
            string += "Address: \(String(describing: address))\n"
            string += "Lat & Lon: (\(String(describing: lat)), \(String(describing: lon)))\n"
            string += "CatchCopy: \(String(describing: catchCopy))\n"
            string += "hasCoupon: \(hasCoupon)\n"
            string += "Station: \(String(describing: station))\n"
            return string
        }
    }
}
