//
//  FavoriteManager.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/6/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import Foundation

public class FavoriteManager
{
    var favorites = [String]()
    
    static let shared: FavoriteManager = {
        let instance = FavoriteManager()
        // setup code
        return instance
    }()
    
    func loadFavorites()
    {
        let ud = UserDefaults.standard
        ud.register(defaults: ["favorites": [String]()])
        favorites = ud.object(forKey: "favorites") as! [String]
    }
    
    func saveFavorites(){
        let ud = UserDefaults.standard
        ud.set(favorites, forKey: "favorites")
        ud.synchronize()
    }
    
    func addFavorites(gid: String?)
    {
        if gid == nil || gid == "" { return }
        
        if favorites.contains((gid!)) {
            removeFavorites(gid: gid!)
        }
        favorites.append(gid!)
        saveFavorites()
    }
    
    func removeFavorites(gid: String?){
        if gid == nil || gid == "" { return }
        
        if let index = favorites.index(of: gid!)
        {
            favorites.remove(at: index)
        }
        saveFavorites()
    }
    
    func toggle(gid: String?)
    {
        if gid == nil || gid == "" { return }
    
        if inFavorites(gid: gid!)
        {
            removeFavorites(gid: gid!)
        }
        else
        {
            addFavorites(gid: gid!)
        }
    }
    
    public func inFavorites(gid: String?) -> Bool {
        if gid == nil || gid == "" { return false }
        
        return favorites.contains((gid!))
    }
    
    public func moveFavorites(sourceIndex: Int, _ destinationIndex: Int){
        if sourceIndex >= favorites.count || destinationIndex >= favorites.count {
            return
        }
        
        let srcGid = favorites[sourceIndex]
        favorites.remove(at: sourceIndex)
        favorites.insert(srcGid, at: destinationIndex)
        
        saveFavorites()
    }
}
