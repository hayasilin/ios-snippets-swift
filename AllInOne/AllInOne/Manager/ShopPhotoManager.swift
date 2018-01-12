//
//  ShopPhotoManager.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/11/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import Foundation
import UIKit

public class ShopPhotoManager
{
    var photos = [String: [String]]()
    var names = [String: String]()
    var gids = [String]()
    let path: String
    
    static let sharedInstance: ShopPhotoManager = {
        let instance = ShopPhotoManager()
        
        return instance!
    }()
    
    init?()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        if paths.count > 0
        {
            path = paths.first!
        }
        else
        {
            path = ""
            return nil
        }
        
        loadPhotos()
    }
    
    func loadPhotos()
    {
        photos.removeAll()
        names.removeAll()
        gids.removeAll()
        
        let ud = UserDefaults.standard
        ud.register(defaults: [
            "photos": [String: [String]](),
            "names": [String: String](),
            "gids": [String]()
            ])
        
        ud.synchronize()
        
        if let photos = ud.object(forKey: "photos") as? [String: [String]]
        {
            self.photos = photos
        }
        
        if let names = ud.object(forKey: "names") as? [String: String]
        {
            self.names = names
        }
        
        if let gids = ud.object(forKey: "gids") as? [String]
        {
            self.gids = gids
        }
        
        print("photos = \(photos)")
        print("names = \(names)")
        print("gids = \(gids)")
    }
    
    func savePhotos()
    {
        let ud = UserDefaults.standard
        ud.set(photos, forKey: "photos")
        ud.set(names, forKey: "names")
        ud.set(gids, forKey: "gids")
        
        ud.synchronize()
    }
    
    func appendPhotos(_ shop: Shop, _ image: UIImage)
    {
        if shop.gid == nil { return }
        if shop.name == nil { return }
        
        let filename = "/" + UUID().uuidString + ".jpg"
        let fullPath = path.appending(filename)
        let fileUrl = URL(fileURLWithPath: fullPath)
        
        let data = UIImageJPEGRepresentation(image, 1)
        
        do
        {
            try data?.write(to: fileUrl, options: Data.WritingOptions.atomic)
        }
        catch
        {
            print(error)
            return
        }
        
        if let data = try? Data(contentsOf: fileUrl)
        {
            let loadImage = UIImage(data: data)!
            print("saved Image = \(loadImage)")
        }
        else
        {
            print("讀取圖片失敗")
        }
        
        if photos[shop.gid!] == nil
        {
            photos[shop.gid!] = [String]()
        }
        else
        {
            gids = gids.filter{ $0 != shop.gid! }
        }
        
        gids.append(shop.gid!)
        photos[shop.gid!]?.append(filename)
        names[shop.gid!] = shop.name
        
        savePhotos()
    }
    
    public func getImage(_ gid: String, _ index: Int) -> UIImage
    {
        if photos[gid] == nil { return UIImage() }
        if index >= (photos[gid]?.count)! { return UIImage() }
        
        if let filename = photos[gid]?[index]
        {
            let fullpath = path.appending(filename)
            
            if let image = UIImage(contentsOfFile: fullpath)
            {
                return image
            }
        }
        
        return UIImage()
    }
    
    public func getCount(_ gid: String) -> Int
    {
        if photos[gid] == nil { return 0 }
        return photos[gid]!.count
    }
    
    public func numberOfPhotosInIndex(_ index: Int) -> Int
    {
        if index >= gids.count { return 0 }
        
        if let photos = photos[gids[index]]
        {
            return photos.count
        }
        
        return 0
    }
    
    
}
