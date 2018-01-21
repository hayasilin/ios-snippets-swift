//
//  UserData+CoreDataProperties.swift
//  CoreDataDemo_Swift
//
//  Created by Kuan-Wei Lin on 1/21/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var iid: String?
    @NSManaged public var cname: String?
    @NSManaged public var own: NSSet?

}

// MARK: Generated accessors for own
extension UserData {

    @objc(addOwnObject:)
    @NSManaged public func addToOwn(_ value: Car)

    @objc(removeOwnObject:)
    @NSManaged public func removeFromOwn(_ value: Car)

    @objc(addOwn:)
    @NSManaged public func addToOwn(_ values: NSSet)

    @objc(removeOwn:)
    @NSManaged public func removeFromOwn(_ values: NSSet)

}
