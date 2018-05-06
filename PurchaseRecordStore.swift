//
//  PurchaseRecordStore.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/9/13.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import CoreData
import QorumLogs

class PurchaseRecordStore {
    var coreDataStack = CoreDataStack(modelName: Utils.Model_Name)
    
    
    func save(record: PurchaseRecord) -> PurchaseRecordEntity? {
        
        //存储登录的信息
        let context = coreDataStack.mainQueueContext
        var recordEntity: PurchaseRecordEntity!
        context.performAndWait() {
            recordEntity = NSEntityDescription.insertNewObject(forEntityName: "PurchaseRecordEntity", into: context) as! PurchaseRecordEntity
            recordEntity.productId = record.productId
            recordEntity.payTime = record.payTime
            recordEntity.userid = record.userid
            recordEntity.isnotify = record.isNotify as NSNumber
        }
        
        do {
            try coreDataStack.saveChanges()
        }
        catch let error {
            print("Core Data save failed: \(error)")
            return nil
        }
        return recordEntity
    }
    
    
    func update() -> Bool {
        do {
            try coreDataStack.saveChanges()
        }
        catch let error {
            print("Core Data save failed: \(error)")
            return false
        }
        return true
        
    }
    
    func getNotNotifyRecord(userid: String) -> PurchaseRecordEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PurchaseRecordEntity")
        fetchRequest.sortDescriptors = nil
        let predict1 = NSPredicate(format: "userid = %@", userid)
        let predict2 = NSPredicate(format: "isnotify = %@", false as CVarArg)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predict1, predict2])
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueUsers: [PurchaseRecordEntity]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait() {
            do {
                mainQueueUsers = try mainQueueContext.fetch(fetchRequest) as? [PurchaseRecordEntity]
            }
            catch let error {
                fetchRequestError = error
                NSLog("GetLoginUser()出现异常")
            }
        }
        
        if fetchRequestError == nil {
            if mainQueueUsers?.count == 0 {
                return nil
            } else {
                return mainQueueUsers![0]
            }
        }
        
        return nil
    }
    
    func getAllNotifyRecord(userid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PurchaseRecordEntity")
        fetchRequest.sortDescriptors = nil
        let predict1 = NSPredicate(format: "userid = %@", userid)
        fetchRequest.predicate = predict1
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueUsers: [PurchaseRecordEntity]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait() {
            do {
                mainQueueUsers = try mainQueueContext.fetch(fetchRequest) as? [PurchaseRecordEntity]
            }
            catch let error {
                fetchRequestError = error
                NSLog("GetLoginUser()出现异常")
            }
        }
        
        if mainQueueUsers == nil {
            QL1("-----------------not any records-------------------")
            return
        }
        for item in mainQueueUsers! {
            QL1("------------------------------------")
            QL1("userid = \(item.userid)")
            QL1("productId = \(item.productId)")
            QL1("payTime = \(item.payTime)")
            QL1("isNotify = \(item.isnotify)")
        }

    }

    
    
    
   }
