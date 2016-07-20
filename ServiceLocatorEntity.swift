//
//  ServiceLocatorEntity.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import CoreData


class ServiceLocatorEntity: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    
    var needServieLocator : Bool {
        get {
            if isUseServiceLocator == nil {
                return true
            }
            
            return "1" == isUseServiceLocator
        }
    }

}
