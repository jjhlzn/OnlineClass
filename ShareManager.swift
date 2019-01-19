//
//  ShareManager.swift
//  jufangzhushou
//
//  Created by 金军航 on 17/2/22.
//  Copyright © 2017年 tbaranes. All rights reserved.
//

import Foundation
import Alamofire
import QorumLogs
import Kanna

class ShareManager {
    
    var controller : UIViewController!
    
    var weixin : WeixinShareService!;
    var weibo : WeiboShareService!;
    var qq : QQShareService!;
    
    private var _shareTitle = ""
    private var _shareUrl = ""
    private var _shareDescription = ""
    private var _shareImage = "" //base64 encode string
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
    
    var shareDescription : String {
        get {
            return _shareDescription
        }
        
        set {
            if newValue != "" {
                _shareDescription = newValue
            }
        }
    }
    
    var shareImage : String {
        get {
            return _shareImage
        }
        set {
            if newValue != ""  {
                _shareImage = newValue
            }
        }
    }
    
    func loadShareInfo(url: URL) {
        //self.resetDefaultSetting()
        //QL1("load share info url: \(url)")
        Alamofire.request(url.absoluteString)
            .responseString { response in
                //QL1("\(response)")
                if let doc = try? HTML(html: response.result.value!, encoding: String.Encoding.utf8) {
                    if  doc.title != nil {
                        
                        var title = doc.title!
                        title = title.trimmingCharacters(in: CharacterSet.whitespaces)
                        self.shareTitle = title
                        //QL1("title = \(title)")
                    }
                    
                    // Search for nodes by XPath
                    for meta in doc.xpath("//meta") {
                        //print(meta.text)
                        //print(meta["name"])
                        //print(meta["content"])
                        
                        if meta["name"] != nil && meta["name"]! == "shareurl" && meta["content"] != nil{
                            self.shareUrl = meta["content"]!
                            //QL1(self.shareUrl)
                        }
                        
                        if meta["name"] != nil && meta["name"]! == "description" && meta["content"] != nil{
                            self.shareDescription = meta["content"]!
                            //QL1(self.shareDescription)
                        }
                        
                    }
                }
        }
    }

    var defaultShareTitle = "扫一扫下载安装【知得】，在线学习信用卡、贷款、股票、基金、投资、理财、保险、财务等金融知识！"
    func resetDefaultSetting()  {
        _shareTitle = defaultShareTitle
        let loginUser = LoginUserStore().getLoginUser()!
        _shareUrl = ServiceLinkManager.ShareQrImageUrl + "?userid=\(loginUser.userName!)"
        _shareDescription = "知得"
        
    }
    
    init(controller : UIViewController) {
        self.controller = controller
        _shareTitle = defaultShareTitle
        _shareDescription = ""
        
        if LoginUserStore().getLoginUser() != nil {
            let loginUser = LoginUserStore().getLoginUser()!
            _shareUrl = ServiceLinkManager.ShareQrImageUrl + "?userid=\(loginUser.userName!)"
            weixin = WeixinShareService(controller: controller, shareManager: self)
            weibo = WeiboShareService(controller: controller, shareManager: self)
            qq = QQShareService(controller: controller, shareManager: self)
            tencentOAuth = TencentOAuth.init(appId: AppDelegate.qqAppId, andDelegate: nil)
        }
    }
    
    @objc func shareToWeixinFriend() {
        weixin.shareToFriend()
    }
    
    @objc func shareToWeixinPengyouquan() {
        weixin.shareToPengyouquan()
    }
    
    @objc func shareToWeibo() {
        weibo.share()
    }
    
    @objc func shareToQQFriend() {
        qq.shareToFriends()
    }
    
    @objc func shareToQzone() {
        qq.shareToQzone()
    }
    
    @objc func copyLink() {
        QL1("copyLink clicked")
        UIPasteboard.general.string =  shareUrl
        ToastMessage.showMessage(view: controller.view, message: "复制成功")
    }
}


class WeixinShareService {
    var controller : UIViewController
    var shareManager : ShareManager
    
    init(controller : UIViewController, shareManager : ShareManager) {
        self.controller = controller
        self.shareManager = shareManager
    }
    
    func shareToFriend(){
        if !Utils.hasInstalledWeixin() {
            Utils.displayMessage(message: "请先安装微信客户端")
        } else {
            share(isPengyouquan: false)
        }
    }
    
    func shareToPengyouquan() {
        if !Utils.hasInstalledWeixin() {
            Utils.displayMessage(message: "请先安装微信客户端")
        } else {
            print("share to pengyouquan")
            share(isPengyouquan: true)
        }
    }
    
    private func share(isPengyouquan: Bool) {
        let message = WXMediaMessage()
        message.title = shareManager.shareTitle
        message.description = shareManager.shareDescription
        
        if shareManager.shareImage != "" {
            let encodedImageData = shareManager.shareImage
            let imageData = Data(base64Encoded: encodedImageData)!
            
            let image = UIImage(data: imageData )
            message.setThumbImage(image)
            
        } else {
            if shareManager.isUseQrImage {
                message.setThumbImage(UIImage(named: "smallAppIcon"))
            } else {
                message.setThumbImage(UIImage(named: "smallAppIcon"))
            }
        }
        
        //message.setThumbImage(image: UIImage()
        //UIImage(
        
        let webPageObject = WXWebpageObject()
        webPageObject.webpageUrl = shareManager.shareUrl
        message.mediaObject = webPageObject
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = (isPengyouquan ? 1 : 0)
        
        WXApi.send(req)
    }

}

class WeiboShareService {
    
    var controller : UIViewController
    var shareManager : ShareManager
    
    init(controller : UIViewController, shareManager : ShareManager) {
        self.controller = controller
        self.shareManager = shareManager
    }

    func share() {
        let req = WBSendMessageToWeiboRequest()
        req.message = getWebpageObject()
        WeiboSDK.send(req)
    }
    
    private func getWebpageObject()-> WBMessageObject
    {
        let message = WBMessageObject()
        
        let webpage = WBWebpageObject()
        webpage.objectID = "\(NSDate().timeIntervalSince1970 * 1000)"
        webpage.title = shareManager.shareTitle
        webpage.description =  shareManager.shareDescription
        
        
        
        //webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
        if shareManager.shareImage != "" {
            let encodedImageData = shareManager.shareImage
            let imageData = Data(base64Encoded: encodedImageData)!
            
            let image = UIImage(data: imageData )
            webpage.thumbnailData = UIImagePNGRepresentation(image!)
        } else {
            if shareManager.isUseQrImage {
                webpage.thumbnailData = UIImagePNGRepresentation(UIImage(named: "smallAppIcon")!)
            } else {
                webpage.thumbnailData = UIImagePNGRepresentation(UIImage(named: "smallAppIcon")!)
            }
        }
        
        webpage.webpageUrl = shareManager.shareUrl
        message.mediaObject = webpage
        //message.text = shareManager.shareDescription
        
        return message
    }
}

class QQShareService {
    
    var controller : UIViewController
    var shareManager : ShareManager
    
    init(controller : UIViewController, shareManager : ShareManager) {
        self.controller = controller
        self.shareManager = shareManager
    }

    
    func shareToFriends() {
        if !Utils.hasInstalledQQ() {
            Utils.displayMessage(message: "请先安装QQ客户端")
        } else {
            shareToQQ(isToQZone: false)
        }
    }
    
    @IBAction func shareToQzone() {
        if !Utils.hasInstalledQQ() {
            Utils.displayMessage(message: "请先安装QQ客户端")
        } else {
            shareToQQ(isToQZone: true)
        }
    }

    private func shareToQQ(isToQZone: Bool) {
        let newsUrl = URL(string: shareManager.shareUrl)
        let title = shareManager.shareTitle
        let description = shareManager.shareDescription
        
        
        let imageName = "smallAppIcon"
        var image = UIImage(named: imageName)!
        if shareManager.shareImage != "" {
            let encodedImageData = shareManager.shareImage
            let imageData = Data(base64Encoded: encodedImageData)!
            
            image = UIImage(data: imageData )!
        }
        let newsObj = QQApiNewsObject(url: newsUrl!, title: title,
                                      description: description,
                                      previewImageData: UIImagePNGRepresentation(image),
                                      targetContentType: QQApiURLTargetTypeNews)
        
        let req = SendMessageToQQReq(content: newsObj)
        
        if isToQZone {
            QQApiInterface.sendReq(toQZone: req)
        } else {
            QQApiInterface.send(req)
        }
        
        
    }


    
}
