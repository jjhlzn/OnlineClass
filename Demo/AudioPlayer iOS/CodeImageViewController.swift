//
//  CodeImageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/8.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import Kingfisher

class CodeImageViewController: BaseUIViewController {
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pengyouquanButton: UIButton!
    @IBOutlet weak var wechatButton: UIButton!
    
    @IBOutlet weak var codeImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginUser = LoginUserStore().getLoginUser()!
        
        if loginUser.codeImageUrl != nil {
            codeImageView.kf_setImageWithURL(NSURL(string: loginUser.codeImageUrl!)!)
        }
        
        addLineBorder(cancelButton)
        shareView.hidden = true
        
        
    }
    
    func addLineBorder(field: UIButton) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, 0, field.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        field.layer.addSublayer(bottomBorder)
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        showShareView()
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        hideShareView()
    }
    
    var shareViewOverlay : UIView!
    
    func showShareView() {
        if !shareView.hidden {
            return
        }
        print("showShareView")
        shareViewOverlay = UIView(frame: UIScreen.mainScreen().bounds)
        shareViewOverlay.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
        shareView.removeFromSuperview()
        shareViewOverlay.addSubview(shareView)
        
        view.addSubview(shareViewOverlay)
        
        shareView.hidden = false
        
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            print("winxin share is OK")
        } else {
            print("winxin share is  NOT OK")
        }
    }
    
    func hideShareView() {
        shareView.hidden = true
        shareView.removeFromSuperview()
        view.addSubview(shareView)
        shareViewOverlay.removeFromSuperview()
    }
    
    
    
    @IBAction func shareToFriends(sender: AnyObject) {
        print("share to friends")
        share(false)
        
        
    }

    @IBAction func shareToPengyouquan(sender: AnyObject) {
        print("share to pengyouquan")
        share(true)
    }
    
    private func share(isPengyouquan: Bool) {
        let message = WXMediaMessage()
        message.title = "扫一扫下载安装【巨方助手】，即可免费在线学习、提额、办卡、贷款！"
        message.description = "扫一扫下载安装【巨方助手】"
        message.setThumbImage(UIImage(named: "me_qrcode"))
        
        let webPageObject = WXWebpageObject()
        let loginUser = LoginUserStore().getLoginUser()!
        webPageObject.webpageUrl = ServiceLinkManager.ShareQrImageUrl + "?userid=\(loginUser.userName)"
        message.mediaObject = webPageObject
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = (isPengyouquan ? 1 : 0)
        
        WXApi.sendReq(req)
        
        
    }

}
