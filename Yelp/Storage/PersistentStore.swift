//
//  PersistentStore.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-23.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import CoreData

class PersistentStore: NSObject {

    // MARK: - Properties
    static var favourites: Set<String> {
        set {
            user?.favourites = newValue
        }
        get {
            return user?.favourites ?? []
        }
    }
    
    static var user: User? {
        get {
            let managedObjectContext = container.viewContext
            var result = [User]()
            do {
                //Get current user
                if let records = try managedObjectContext.fetch(User.fetchRequest()) as? [User] {
                    result = records
                }
            } catch {

            }
            
            if let item = result.first {
                return item
            }
            
            let user = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(User.self), into: managedObjectContext) as? User
            do {
                try managedObjectContext.save()
            } catch {
                // failed saving
            }
            
            return user
        }
    }
    
    static private  var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Yelp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Updates
    static func save() {
        let context = container.viewContext
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
