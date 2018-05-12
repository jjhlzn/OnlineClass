//
//  DeviceExtension.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/10.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

extension UIDevice {
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        
        return false
    }
}
