//
//  ShareView.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/12.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class ShareView: BaseCustomView {
    var controller : UIViewController!
    var shareManager : ShareManager!
    var overlay: UIView!
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var weixinFriendBtn: UIButton!
    @IBOutlet weak var weixinPengyouqquanBtn: UIButton!
    @IBOutlet weak var weiboBtn: UIButton!
    @IBOutlet weak var qqFriendBtn: UIButton!
    @IBOutlet weak var qqZoneBtn: UIButton!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    var isShow = false
    
    init(frame: CGRect, controller : UIViewController) {
        super.init(frame: frame)
        self.controller = controller
        
        overlay = UIView(frame: UIScreen.main.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
        shareManager = ShareManager(controller: controller)
        copyBtn.addTarget(shareManager, action: #selector(shareManager.copyLink), for: .touchUpInside)
        weixinFriendBtn.addTarget(shareManager, action: #selector(shareManager.shareToWeixinFriend), for: .touchUpInside)
        weixinPengyouqquanBtn.addTarget(shareManager, action: #selector(shareManager.shareToWeixinPengyouquan), for: .touchUpInside)
        qqZoneBtn.addTarget(shareManager, action: #selector(shareManager.shareToQzone), for: .touchUpInside)
        weiboBtn.addTarget(shareManager, action: #selector(shareManager.shareToWeibo), for: .touchUpInside)
        qqFriendBtn.addTarget(shareManager, action: #selector(shareManager.shareToQQFriend), for: .touchUpInside)
        
        
        cancelBtn.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
    }
    
    
    @objc func cancelPressed() {
        overlay.removeFromSuperview()
        self.removeFromSuperview()
        isShow = false
    }
    
    func show() {
        controller.view.addSubview(overlay)
        controller.view.addSubview(self)
        isShow = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setShareUrl(_ url: String) {
        shareManager.shareUrl = url
    }
}
