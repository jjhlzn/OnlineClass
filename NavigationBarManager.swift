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
    
    func setMusicButton(_ alpha : CGFloat = 1, needUpdate: Bool = true, isWhite: Bool = false) {
        if !needUpdate {
            return
        }
        let customView = getMusicCustomView(alpha, isWhite: isWhite)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: 21))
        container.addSubview(customView)
        //container.backgroundColor = UIColor.red
        let musicButton = UIBarButtonItem(customView: container)
        viewController.navigationItem.rightBarButtonItems?.append(musicButton)
        if #available(iOS 11.0, *) {
            musicButton.customView?.snp.makeConstraints({ (make) in
                make.width.equalTo(21)
                make.height.equalTo(21)
            })
        }
    }
    
    
    func getMusicCustomView(_ alpha : CGFloat = 1, isWhite: Bool = false) -> UIView {
        let audioPlayer = Utils.getAudioPlayer()
        var xOffset = 2
        if UIDevice().isIphone5Like() {
            xOffset = 7
        } else if UIDevice().isX() {
            xOffset = 1
        } else if UIDevice().isIphonePlusLike() {
            xOffset = 4
        }
        if audioPlayer.state == AudioPlayerState.playing {
            self.imageView = GIFImageView(frame: CGRect(x: xOffset, y: -2, width: 21, height: 21))
            if alpha < 0.01 {
                self.imageView.isHidden = true
            } else {
                self.imageView.isHidden = false
            }
            self.imageView.backgroundColor = nil
            self.imageView.alpha = alpha
            if isWhite {
                self.imageView.animate(withGIFNamed: "demo_white")
            } else {
                self.imageView.animate(withGIFNamed: "demo")
            }
            
            self.imageView.setNeedsDisplay()
            self.imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMusicBtnHandler(sender:))))
            return self.imageView
        } else {
            self.staticImageView = UIImageView(frame: CGRect(x: xOffset, y: -2, width: 21, height: 21))
            if alpha < 0.01 {
                self.staticImageView.isHidden = true
            } else {
                self.staticImageView.isHidden = false
            }
            if isWhite {
                self.staticImageView.image = UIImage(named: "music_static_white")
            } else {
                self.staticImageView.image = UIImage(named: "music_static")
            }

            self.staticImageView.alpha = alpha
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
            
            vc.hasBottomBar = false
            
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
        b.frame = CGRect(x: 5, y: -2, width: 50, height: 24)
        //b.backgroundColor = UIColor.blue
        
        b.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 24))
        view.addSubview(b)
        let button = UIBarButtonItem(customView: view)

        viewController.navigationItem.rightBarButtonItems?.append(button)
        
    }
    
    @objc func sharePressed() {
        shareView?.show()
    }
}





