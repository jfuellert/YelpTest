//
//  User+CoreDataProperties.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-24.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var authenticationToken: String?
    @NSManaged public var favourites: Set<String>?

}
