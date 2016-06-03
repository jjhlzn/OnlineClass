//
//  ServiceLocatorEntity+CoreDataProperties.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ServiceLocatorEntity {

    @NSManaged var http: String?
    @NSManaged var serverName: String?
    @NSManaged var port: NSNumber?

}
