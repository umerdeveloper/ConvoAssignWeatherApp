//
//  CoreDataService.swift
//  ConvoAssignWeatherApp
//
//  Created by Umer Khan on 28/05/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import CoreData

class CoreDataService {
    
    private init() { }
    
    static let shared = CoreDataService()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "WeatherModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
