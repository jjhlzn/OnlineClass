//
//  UserProfilePhotoStore.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/24.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit

class UserProfilePhotoStore : ImageStore {
    override var imageName : String {
        get {
            return "userimage.png"
        }
    }
}