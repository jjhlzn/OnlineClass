//
//  MyUISlider.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/5.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class MyUISlider: UISlider {
    
    
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        
        return CGRectMake(0, 13, UIScreen.mainScreen().bounds.width, 4)
    }

}


