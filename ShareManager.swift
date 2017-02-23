//
//  ShareManager.swift
//  jufangzhushou
//
//  Created by 金军航 on 17/2/22.
//  Copyright © 2017年 tbaranes. All rights reserved.
//

import Foundation


class ShareManager {
    
    var controller : BaseUIViewController!
    
    var weixin : WeixinShareService!;
    var weibo : WeiboShareService!;
    var qq : QQShareService!;
    
    private var _shareTitle = ""
    private var _shareUrl = ""
    var isUseQrImage = true
    
    var tencentOAuth:TencentOAuth!
    
    var shareTitle : String {
        get {
            return _shareTitle
        }
        
        set {
            if newValue != "" {
                _shareTitle = newValue
            }
        }
    }
    
    var shareUrl : String {
        get {
            return _shareUrl
        }
        set {
            if newValue != "" {
                _shareUrl = newValue
            }
        }
    }
    
    init(controller : BaseUIViewController) {
        self.controller = controller
        _shareTitle = "扫一扫下载安装【巨方助手】，即可免费在线学习、提额、办卡、贷款！"
        let loginUser = LoginUserStore().getLoginUser()!
        _shareUrl = ServiceLinkManager.ShareQrImageUrl + "?userid=\(loginUser.userName!)"
        weixin = WeixinShareService(controller: controller, shareManager: self)
        weibo = WeiboShareService(controller: controller, shareManager: self)
        qq = QQShareService(controller: controller, shareManager: self)
        tencentOAuth = TencentOAuth.init(appId: AppDelegate.qqAppId, andDelegate: nil)
    }
    
    func shareToWeixinFriend() {
        weixin.shareToFriend()
    }
    
    func shareToWeixinPengyouquan() {
        weixin.shareToPengyouquan()
    }
    
    func shareToWeibo() {
        weibo.share()
    }
    
    func shareToQQFriend() {
        qq.shareToFriends()
    }
    
    func shareToQzone() {
        qq.shareToQzone()
    }
    
    func copyLink() {
        UIPasteboard.generalPasteboard().string =  shareUrl
        ToastMessage.showMessage(controller.view, message: "复制成功")
    }
}


class WeixinShareService {
    var controller : BaseUIViewController
    var shareManager : ShareManager
    
    init(controller : BaseUIViewController, shareManager : ShareManager) {
        self.controller = controller
        self.shareManager = shareManager
    }
    
    func shareToFriend(){
        if !Utils.hasInstalledWeixin() {
            controller.displayMessage("请先安装微信客户端")
        } else {
            share(false)
        }
    }
    
    func shareToPengyouquan() {
        if !Utils.hasInstalledWeixin() {
            controller.displayMessage("请先安装微信客户端")
        } else {
            print("share to pengyouquan")
            share(true)
        }
    }
    
    private func share(isPengyouquan: Bool) {
        let message = WXMediaMessage()
        message.title = shareManager.shareTitle
        message.description = ""
        
        if shareManager.isUseQrImage {
            message.setThumbImage(UIImage(named: "me_qrcode"))
        } else {
            message.setThumbImage(UIImage(named: "smallAppIcon"))
        }
        
        let webPageObject = WXWebpageObject()
        webPageObject.webpageUrl = shareManager.shareUrl
        message.mediaObject = webPageObject
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = (isPengyouquan ? 1 : 0)
        
        WXApi.sendReq(req)
    }

}

class WeiboShareService {
    
    var controller : BaseUIViewController
    var shareManager : ShareManager
    
    init(controller : BaseUIViewController, shareManager : ShareManager) {
        self.controller = controller
        self.shareManager = shareManager
    }

    func share() {
        let req = WBSendMessageToWeiboRequest()
        req.message = getWebpageObject()
        WeiboSDK.sendRequest(req)
    }
    
    private func getWebpageObject()-> WBMessageObject
    {
        let message = WBMessageObject()
        
        let webpage = WBWebpageObject()
        webpage.objectID = "\(NSDate().timeIntervalSince1970 * 1000)"
        webpage.title = shareManager.shareTitle
        webpage.description =  ""
        
        //webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
        if shareManager.isUseQrImage {
            webpage.thumbnailData = UIImagePNGRepresentation(UIImage(named: "me_qrcode")!)
        } else {
            webpage.thumbnailData = UIImagePNGRepresentation(UIImage(named: "smallAppIcon")!)
        }
        
        webpage.webpageUrl = shareManager.shareUrl
        message.mediaObject = webpage
        
        return message
    }
}

class QQShareService {
    
    var controller : BaseUIViewController
    var shareManager : ShareManager
    
    init(controller : BaseUIViewController, shareManager : ShareManager) {
        self.controller = controller
        self.shareManager = shareManager
    }

    
    func shareToFriends() {
        if !Utils.hasInstalledQQ() {
            controller.displayMessage("请先安装QQ客户端")
        } else {
            shareToQQ(false)
        }
    }
    
    @IBAction func shareToQzone() {
        if !Utils.hasInstalledQQ() {
            controller.displayMessage("请先安装QQ客户端")
        } else {
            shareToQQ(true)
        }
    }

    private func shareToQQ(isToQZone: Bool) {
        let newsUrl = NSURL(string: shareManager.shareUrl)
        let title = shareManager.shareTitle
        let description = ""
        
        var imageName = "me_qrcode"
        if !shareManager.isUseQrImage {
            imageName = "smallAppIcon"
        }
        
        let newsObj = QQApiNewsObject(URL: newsUrl!, title: title, description: description, previewImageData: UIImagePNGRepresentation(UIImage(named: imageName)!), targetContentType: QQApiURLTargetTypeNews)
        
        let req = SendMessageToQQReq(content: newsObj)
        
        if isToQZone {
            QQApiInterface.SendReqToQZone(req)
        } else {
            QQApiInterface.sendReq(req)
        }
        
        
    }


    
}