//
//  MyGIfImageView.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/9.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import Gifu

class MyGifImageView: UIImageView, GIFAnimatable {
    public lazy var animator: Animator? = {
        return Animator(withDelegate: self)
        
    }()
    
    override public func display(_ layer: CALayer) {
        updateImageIfNeeded()
    }
}
