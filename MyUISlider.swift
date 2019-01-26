//
//  MyUISlider.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/5.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class MyUISlider: UISlider {
    
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        
        return CGRect(x: 0, y: 12, width: UIScreen.main.bounds.width, height: 4.5)
    }

}


