//
//  MainPageNavigationBar.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/9/23.
//  Copyright © 2018 tbaranes. All rights reserved.
//

import UIKit

class MainPageNavigationBar: NSObject {
    
    var controller : CourseMainPageViewController!
    var navigationManager : NavigationBarManager!
    
    func setNavigationBarForState3() {
        controller.navigationItem.rightBarButtonItems = []
        navigationManager.setMusicButton(needUpdate: true, isWhite: false)
        
        //setKefuButton()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        let searchLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        view.addSubview(searchLabel)
        searchLabel.layer.masksToBounds = true
        searchLabel.layer.cornerRadius = 4
        searchLabel.backgroundColor =  UIColor(white: 1, alpha: 1)
        searchLabel.text = "探索"
        searchLabel.textColor =  UIColor.black
        searchLabel.font = UIFont.boldSystemFont(ofSize: 17)
        searchLabel.textAlignment = .center
        controller.navigationItem.titleView = view
        
    }
    
    
    func setNavigationBarForState1(_ alpha : CGFloat = 1) {
        controller.navigationItem.rightBarButtonItems = []
        navigationManager.setMusicButton(alpha, isWhite: true)
        //setKefuButton()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.94, height: 46))
        let searchLabel = UILabel(frame: CGRect(x: 6, y: 2, width: UIScreen.main.bounds.width * 0.82, height: 36))
        view.addSubview(searchLabel)
        searchLabel.layer.masksToBounds = true
        searchLabel.layer.cornerRadius = 4
        searchLabel.backgroundColor =  UIColor(white: 1, alpha: alpha)
        //searchLabel.text = "  融资、信用卡、关键词"
        
        searchLabel.font = searchLabel.font.withSize(16)
        searchLabel.textColor =  Utils.hexStringToUIColor(hex: "#97989F").withAlphaComponent(alpha)
        
        //Create Attachment
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = UIImage(named:"searchicon")?.withAlpha(alpha: alpha)

        //Set bound to reposition
        let imageOffsetY:CGFloat = -2;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let completeText = NSMutableAttributedString(string: "  ")
        //Add image to mutable string
        completeText.append(attachmentString)
        //Add your text to mutable string
        let  textAfterIcon = NSMutableAttributedString(string: "  融资、信用卡、关键词")
        completeText.append(textAfterIcon)

        searchLabel.attributedText = completeText;
        
        searchLabel.textAlignment = .left
        searchLabel.isUserInteractionEnabled = true
        
        controller.navigationItem.titleView = view
        let tap = UITapGestureRecognizer(target: controller, action: #selector(controller.tapSearchLabel))
        searchLabel.addGestureRecognizer(tap)
    }
    
    func updateNavigationForOffsetAdust(_ offset : CGFloat = 0, updateAlways : Bool = false) {
        let Y: CGFloat = Utils.getNavigationBarHeight()
        let isTranslucent = !(offset > Y)
        if controller.navigationController?.backdropImageView == nil {
           controller.navigationController?.backdropImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 315, height: Utils.getNavigationBarHeight()))
        }
        
        if offset < 0 {
            let _offset = -offset
            var alpha : CGFloat = 1
            let height : CGFloat = 50
            if _offset > height {
                alpha = 0
            } else {
                alpha =  (height - _offset) / height > 1.0 ? 1 : (height - _offset) / height
            }
            setNavigationBarForState1(alpha)
        } else {
            if isTranslucent {  //透明
                let alpha = (offset / Utils.getNavigationBarHeight()) > 1.0 ? 1 : offset / Utils.getNavigationBarHeight()
                controller.navigationController?.setBarColor(image: UIImage(), color: nil, alpha: alpha)
                let nav = controller.navigationController?.navigationBar
                nav?.barStyle = UIBarStyle.black
                nav?.tintColor = UIColor.white
                setNavigationBarForState1()
            } else {
                controller.navigationController?.setBarColor(image: UIImage(), color: UIColor.white, alpha: 1)
                let nav = controller.navigationController?.navigationBar
                var needUpdate = true
                if nav?.barStyle == UIBarStyle.default {
                    needUpdate = false
                }
                nav?.barStyle = UIBarStyle.default
                nav?.tintColor = UIColor.black
                if needUpdate || updateAlways {
                    setNavigationBarForState3()
                }
                
            }
        }
        
    }

    
    @objc func keFuPressed() {
        var sender = [String:String]()
        sender["title"] = "客服"
        sender["url"] = ServiceLinkManager.FunctionCustomerServiceUrl
        controller.performSegue(withIdentifier: "loadWebPageSegue", sender: sender)
    }

}
