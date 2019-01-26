//
//  UINavigationControllerExtension.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/14.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

// 扩展属性的key
fileprivate var backdropKey: Void?
extension UINavigationController {

    var SCREEN_WIDTH : CGFloat {
        get {
            return UIScreen.main.bounds.width
        }
    }
    
    /// 设置导航栏颜色+透明度
    func setBarColor(image: UIImage?=nil, color: UIColor?, alpha: CGFloat) {
        // 去掉阴影
        navigationBar.shadowImage = UIImage()
        // 把视觉曾遍历设置为纯透明
        for v: UIView in navigationBar.subviews[0].subviews {
            if v.tag != 10054 {
                v.alpha = 0
            }
        }
        // 添加新的视觉图层
        if backdropImageView?.superview == nil {
            backdropImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height:(UIDevice().isX() ? Utils.getNavigationBarHeight() : 64)))
            navigationBar.subviews[0].insertSubview(backdropImageView!, at: 0)
        }
        backdropImageView?.tag = 10054
        backdropImageView?.image = image
        backdropImageView?.backgroundColor = color ?? UIColor.white
        backdropImageView?.alpha = alpha
    }
    
    // 添加一层UIImageView层, 用于展示 (纯色背景 || 指定图片 || 完全透明)
    var backdropImageView: UIImageView? {
        get {
            return objc_getAssociatedObject(self, &backdropKey) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &backdropKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        
    }
}


