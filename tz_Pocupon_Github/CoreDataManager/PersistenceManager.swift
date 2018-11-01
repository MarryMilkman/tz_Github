//
//  PersistenceManager.swift
//  tz_Pocupon_Github
//
//  Created by Ivan SELETSKYI on 10/30/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import Foundation
import CoreData

class PersistentService {
    
    private init() {}
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "tz_Pocupon_Github")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                print("Saved")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func fetch(context: NSManagedObjectContext, _ objectType: NSManagedObject.Type) -> [NSManagedObject] {
        
        let entityName = String(describing: objectType)
        
        let fetchRequst = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let fetchObject = try context.fetch(fetchRequst) as? [NSManagedObject]
            return fetchObject ?? [NSManagedObject]()
        } catch {
            print(error)
        }
        
        return [NSManagedObject]()
    }
}


