//
//  UserProfilePhotoStore.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/24.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit

class QrCodeImageStore : ImageStore {
    override var imageName : String {
        get {
            return "qrimage.png"
        }
    }
}