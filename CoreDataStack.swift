     //
//  CoreDataStack.swift
//  Photorama
//
//  Created by 刘兆娜 on 16/1/22.
//  Copyright © 2016年 Big Nerd Ranch. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let managedObjectModelName : String
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.managedObjectModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private var applicationDocumentDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first! as NSURL
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let pathComponent = "\(self.managedObjectModelName).sqlite"
        let url = self.applicationDocumentDirectory.appendingPathComponent(pathComponent)
        let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
        
        let store = try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                        configurationName: nil,
                                                        at: url, options: options)
        return coordinator
    }()
    
    lazy var mainQueueContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        //moc.name = "Main Queue Context (UI Context)"
        
        return moc
    }()
    
    lazy var privateQueueContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = self.mainQueueContext
        //moc.name = "Primary Private Queue Context"
        return moc
    }()
    
    required init(modelName: String) {
        managedObjectModelName = modelName
    }
    
    func saveChanges() throws {
        var error: Error?
        
        privateQueueContext.performAndWait { () -> Void in
            if self.privateQueueContext.hasChanges {
                print("privateQueueContext has change")
                do {
                    try self.privateQueueContext.save()
                }
                catch let saveError {
                    error = saveError
                }
            }
        }
        
        if let error = error {
            throw error
        }
        
        mainQueueContext.performAndWait() {
            do {
                try self.mainQueueContext.save()
            }
            catch let saveError {
                error = saveError
            }
        }
        
        if let error = error {
            throw error
        }
    }
    
    
}
