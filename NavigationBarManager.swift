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
import SnapKit

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
        //customView.backgroundColor = UIColor.red
        
        let container = UIView(frame: CGRect(x: 8, y: 0, width: 24, height: 24))
        container.addSubview(customView)
        //container.backgroundColor = UIColor.red
        let musicButton = UIBarButtonItem(customView: container)
        viewController.navigationItem.rightBarButtonItems?.append(musicButton)
        if #available(iOS 11.0, *) {
            musicButton.customView?.snp.makeConstraints({ (make) in
                make.width.equalTo(24)
                make.height.equalTo(24)
            })
        }
    }
    
    
    func getMusicCustomView() -> UIView {
        let audioPlayer = Utils.getAudioPlayer()
        if audioPlayer.state == AudioPlayerState.playing {
            self.imageView = GIFImageView(frame: CGRect(x: 8, y: 0, width: 24, height: 24))
            self.imageView.backgroundColor = nil
            self.imageView.animate(withGIFNamed: "demo")
            self.imageView.setNeedsDisplay()
            self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMusicBtnHandler(sender:))))
            return self.imageView
        } else {
            self.staticImageView = UIImageView(frame: CGRect(x: 8, y: 0, width: 24, height: 24))
            self.staticImageView.image = UIImage(named: "music_static")
            staticImageView.isUserInteractionEnabled = true
            let tapHandler = UITapGestureRecognizer(target: self, action: #selector(tapMusicBtnHandler(sender:)))
            staticImageView.addGestureRecognizer(tapHandler)
            return self.staticImageView
        }
    }
    
    @objc func tapMusicBtnHandler(sender: UITapGestureRecognizer? = nil) {
        let audioPlayer = Utils.getAudioPlayer()
        if audioPlayer.currentItem != nil {
            //let vc = viewController(nibName: "nameOfNib", bundle: nil)
            //let vc = NewPlayerController()
            
            //Storyboard
            let viewControllerStoryboardId = "NewPlayerController"
            let storyboardName = "Main"
            let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: viewControllerStoryboardId) as! NewPlayerController
            
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
        //b.backgroundColor = UIColor.red
        b.setImage( UIImage(named: "share_black2"), for: .normal)
        b.frame = CGRect(x: 0, y: 0, width: 50, height: 24)
        //b.backgroundColor = UIColor.blue
        
        b.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 24))
        //view.backgroundColor = UIColor.blue
        //view.backgroundColor = UIColor.red
        view.addSubview(b)
        let button = UIBarButtonItem(customView: view)
        //view.isUserInteractionEnabled = true
        //view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sharePressed)))

        viewController.navigationItem.rightBarButtonItems?.append(button)
        
    }
    
    @objc func sharePressed() {
        shareView?.show()
    }
}





