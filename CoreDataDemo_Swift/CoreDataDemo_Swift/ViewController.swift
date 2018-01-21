//
//  ViewController.swift
//  CoreDataDemo_Swift
//
//  Created by Kuan-Wei Lin on 1/21/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var viewContext: NSManagedObjectContext!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let app = appDelegate()
        
        viewContext = app.persistentContainer.viewContext
        
        print("path = \(NSPersistentContainer.defaultDirectoryURL())")
        
        insertUserData()
        queryUserData()
    }
    
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func insertUserData()
    {
        var user = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: viewContext) as! UserData
        user.iid = "A01"
        user.cname = "David"
        
        user = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: viewContext) as! UserData
        user.iid = "A02"
        user.cname = "Peter"
        
        let app = appDelegate()
        app.saveContext()
    }
    
    func queryUserData()
    {
        do
        {
            let allUsers = try viewContext.fetch(UserData.fetchRequest())
            for user in allUsers as! [UserData]
            {
                print("\(String(describing: user.iid)), \(user.cname)")
            }
        }
        catch
        {
            print("error = \(error)")
        }
    }
}

