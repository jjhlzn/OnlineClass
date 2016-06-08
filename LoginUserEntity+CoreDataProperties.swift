//
//  LoginUserEntity+CoreDataProperties.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LoginUserEntity {

    @NSManaged var userName: String?
    @NSManaged var name: String?
    @NSManaged var token: String?
    @NSManaged var password: String?
    @NSManaged var lastLoginTime: NSDate?

    @NSManaged var sex: String?
    @NSManaged var codeImageUrl: String?
}
