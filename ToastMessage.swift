//
//  ToastMessage.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit

class ToastMessage {
    
    
    static func showMessage(view: UIView!, message: String) {
        
        
        let label = UILabel(frame: CGRectMake(0, 0, 160, 60))
        label.layer.cornerRadius = 05
        label.backgroundColor = UIColor(white: 0.3, alpha: 0.65)
        label.textAlignment = NSTextAlignment.Center
        
        label.text = message
        
        label.center = view.center
        label.textColor =  UIColor.whiteColor()
        label.font = UIFont(name: "System", size: CGFloat(16))
        
        view.addSubview(label)
        Utils.delay(1) {
            label.removeFromSuperview()
        }
        
    }
    
   
}