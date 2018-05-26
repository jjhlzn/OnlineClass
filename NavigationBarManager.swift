//
//  NavigationBarManager.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/22.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import Gifu
import KDEAudioPlayer

class NavigationBarManager: NSObject {

    var viewController: UIViewController!
    var shareView: ShareView?
    
    var imageView: GIFImageView!
    var staticImageView: UIImageView!
    
    //var musicButton : UIBarButtonItem!
    init(_ viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        
    }
    
    func setMusicButton() {
        let customView = getMusicCustomView()
        let musicButton = UIBarButtonItem(customView: customView)
        viewController.navigationItem.rightBarButtonItems?.append(musicButton)
    }
    
    
    func getMusicCustomView() -> UIView {
        let audioPlayer = Utils.getAudioPlayer()
        if audioPlayer.state == AudioPlayerState.playing {
            self.imageView = GIFImageView(frame: CGRect(x: 0, y: -10, width: 32, height: 32))
            self.imageView.backgroundColor = nil
            self.imageView.animate(withGIFNamed: "demo")
            self.imageView.setNeedsDisplay()
            self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMusicBtnHandler(sender:))))
            return self.imageView
        } else {
            self.staticImageView = UIImageView(image: UIImage(named: "music_static"))
            staticImageView.isUserInteractionEnabled = true
            let tapHandler = UITapGestureRecognizer(target: self, action: #selector(tapMusicBtnHandler(sender:)))
            staticImageView.addGestureRecognizer(tapHandler)
            return self.staticImageView
        }
    }
    
    @objc func tapMusicBtnHandler(sender: UITapGestureRecognizer? = nil) {
        let audioPlayer = Utils.getAudioPlayer()
        if audioPlayer.currentItem != nil {
            let vc = NewPlayerController()
            viewController.hidesBottomBarWhenPushed = true
            viewController.navigationController?.pushViewController(vc, animated: true)
            viewController.hidesBottomBarWhenPushed = false
        }
    }
    
    func setMusicBtnState() {
        if self.imageView == nil {
            return
        }
        let audioPlayer = Utils.getAudioPlayer()
        if audioPlayer.state == AudioPlayerState.playing {
            self.imageView.startAnimatingGIF()
        } else {
            self.imageView.stopAnimatingGIF()
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
