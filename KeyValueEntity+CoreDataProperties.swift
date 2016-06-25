//
//  KeyValueEntity+CoreDataProperties.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/25.
//  Copyright © 2016年 tbaranes. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension KeyValueEntity {

    @NSManaged var key: String?
    @NSManaged var value: String?

}
