//
//  ServiceLocatorStore.swift
//  ContractApp
//
//  Created by 刘兆娜 on 16/4/29.
//  Copyright © 2016年 金军航. All rights reserved.
//

import Foundation
import CoreData

class ServiceLocatorStore {
    var coreDataStack = CoreDataStack(modelName: "jufangzhushou")
    
    func GetServiceLocator() -> ServiceLocatorEntity? {
        let fetchRequest = NSFetchRequest(entityName: "ServiceLocatorEntity")
        fetchRequest.sortDescriptors = nil
        fetchRequest.predicate = nil
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueUsers: [ServiceLocatorEntity]?
        var fetchRequestError: ErrorType?
        mainQueueContext.performBlockAndWait() {
            do {
                mainQueueUsers = try mainQueueContext.executeFetchRequest(fetchRequest) as? [ServiceLocatorEntity]
            }
            catch let error {
                fetchRequestError = error
                NSLog("GetServiceLocator()出现异常")
            }
        }
        
        if fetchRequestError == nil {
            if mainQueueUsers?.count == 0 {
                return nil
            } else {
                let entity = mainQueueUsers![0]
                //print("serverName = \(entity.serverName)")
                return entity
            }
        }
        return nil
    }
    
    func saveServiceLocator(serviceLocator: ServiceLocator) -> Bool {
        //存储登录的信息
        let context = coreDataStack.mainQueueContext
        var entity: ServiceLocatorEntity!
        context.performBlockAndWait() {
            entity = NSEntityDescription.insertNewObjectForEntityForName("ServiceLocatorEntity", inManagedObjectContext: context) as! ServiceLocatorEntity
            entity.http = serviceLocator.http
            entity.serverName = serviceLocator.serverName
            entity.port = serviceLocator.port
        }
        
        do {
            try coreDataStack.saveChanges()
        }
        catch let error {
            print("Core Data save failed: \(error)")
            return false
        }
        return true
    }
    
    func UpdateServiceLocator() -> Bool {
        do {
            try coreDataStack.saveChanges()
        }
        catch let error {
            print("Core Data save failed: \(error)")
            return false
        }
        return true
        
    }
    
}