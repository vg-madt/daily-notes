//
//  coreDataManager.swift
//  notesapp
//
//  Created by admin on 6/14/20.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    var container: NSPersistentContainer{
        let container = NSPersistentContainer(name: "notesapp")
        container.loadPersistentStores{(description, error) in
            guard error == nil else{
                print("Error: \(error!)")
                return
            }
        }
        return container
    }
    
    var managedContext: NSManagedObjectContext{
        return container.viewContext
    }
    
    
}
