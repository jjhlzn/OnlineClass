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
        if UIScreen.main.bounds.height == 812 || UIScreen.main.bounds.height == 896  {
            return true
        }
        
        return false
    }
    
    public func isXMax() -> Bool {
        if  UIScreen.main.bounds.height == 896  {
            return true
        }
        
        return false
    }
    
    public func isIphone5Like() -> Bool {
        if UIScreen.main.bounds.height == 568 {
            return true
        }
        
        return false
    }
    public func isIphone6Like() -> Bool {
        if UIScreen.main.bounds.height == 667 {
            return true
        }
        
        return false
    }
    public func isIphonePlusLike() -> Bool {
        if UIScreen.main.bounds.height == 736 {
            return true
        }
        
        return false
    }
    
    public func isIphone4Like() -> Bool {
        return abs(UIScreen.main.bounds.width - 320) < 1;
    }
}
