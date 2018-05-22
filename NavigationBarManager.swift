//
//  NavigationBarManager.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/22.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import Gifu

class NavigationBarManager: NSObject {

    var viewController: UIViewController!
    var shareView: ShareView?
    
    var imageView: GIFImageView!
    
    init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func setMusicButton() {
        self.imageView = GIFImageView(frame: CGRect(x: 0, y: -10, width: 32, height: 32))
        self.imageView.backgroundColor = nil
        self.imageView.animate(withGIFNamed: "demo")
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMusicBtnHandler(sender:))))
        let button = UIBarButtonItem(customView: self.imageView)
        
        viewController.navigationItem.rightBarButtonItems?.append(button)
    }
    
    @objc func tapMusicBtnHandler(sender: UITapGestureRecognizer? = nil) {
        if self.imageView.isAnimatingGIF {
            self.imageView.stopAnimatingGIF()
        } else {
            self.imageView.startAnimatingGIF()
        }
    }
    
    func setShareButton() {
        let b = UIButton(type: .custom)
        b.setImage( UIImage(named: "share_black2"), for: .normal)
        b.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let view = UIView(frame: CGRect(x: 0, y: 5, width: 45, height: 45))
        view.addSubview(b)
        let button = UIBarButtonItem(customView: view)
        b.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        viewController.navigationItem.rightBarButtonItems?.append(button)
    }
    
    @objc func sharePressed() {
        shareView?.show()
    }
}
