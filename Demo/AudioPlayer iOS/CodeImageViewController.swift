//
//  CodeImageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/8.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import Kingfisher
import QorumLogs

class CodeImageViewController: BaseUIViewController {
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var pengyouquanButton: UIButton!
    @IBOutlet weak var wechatButton: UIButton!
    
    var tencentOAuth:TencentOAuth!
    
    @IBOutlet weak var codeImageView: UIImageView!
    var qrCodeImageStore: QrCodeImageStore!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tencentOAuth = TencentOAuth.init(appId: AppDelegate.qqAppId, andDelegate: nil)
        
        let loginUser = LoginUserStore().getLoginUser()!
        
        qrCodeImageStore = QrCodeImageStore()
        
        
        if loginUser.codeImageUrl != nil {
            QL1("loading code image: \(loginUser.codeImageUrl!)")
            codeImageView.kf_setImageWithURL(NSURL(string: loginUser.codeImageUrl!)!,
                                         placeholderImage: qrCodeImageStore.get(),
                                         optionsInfo: [.ForceRefresh],
                                         completionHandler: { (image, error, cacheType, imageURL) -> () in
                                            if image != nil {
                                                self.qrCodeImageStore.saveOrUpdate(image!)
                                            }
            })
        }
        
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            print("winxin share is OK")
        } else {
            print("winxin share is  NOT OK")
        }
    }
    
    func addLineBorder(field: UIButton) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, 0, field.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        field.layer.addSublayer(bottomBorder)
    }
    

    
    @IBAction func shareToFriends(sender: AnyObject) {
        print("share to friends")
        share(false)
        
        
    }

    @IBAction func shareToPengyouquan(sender: AnyObject) {
        print("share to pengyouquan")
        share(true)
    }
    
    @IBAction func shareToWeibo(sender: AnyObject) {
        let req = WBSendMessageToWeiboRequest()
        req.message = Utils.getWebpageObject()
        WeiboSDK.sendRequest(req)
    }
    
    @IBAction func shareToQQFriends(sender: AnyObject) {
        shareToQQ(false)
    }
    
    
    @IBAction func shareToQzone(sender: AnyObject) {
        shareToQQ(true)
    }
    
    @IBAction func copyLink(sender: AnyObject) {
        let loginUser = LoginUserStore().getLoginUser()!
        UIPasteboard.generalPasteboard().string =  ServiceLinkManager.ShareQrImageUrl + "?userid=\(loginUser.userName!)"
        ToastMessage.showMessage(self.view, message: "复制成功")
    }
    
    
    private func share(isPengyouquan: Bool) {
        let message = WXMediaMessage()
        message.title = "扫一扫下载安装【巨方助手】，即可免费在线学习、提额、办卡、贷款！"
        message.description = "扫一扫下载安装【巨方助手】"
        message.setThumbImage(UIImage(named: "me_qrcode"))
        
        let webPageObject = WXWebpageObject()
        let loginUser = LoginUserStore().getLoginUser()!
        webPageObject.webpageUrl = ServiceLinkManager.ShareQrImageUrl + "?userid=\(loginUser.userName!)"
        message.mediaObject = webPageObject
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = (isPengyouquan ? 1 : 0)
        
        WXApi.sendReq(req)
    }
    
    
    
    
    private func shareToQQ(isToQZone: Bool) {
        let loginUser = LoginUserStore().getLoginUser()!
        let newsUrl = NSURL(string: ServiceLinkManager.ShareQrImageUrl + "?userid=\(loginUser.userName!)")
        let title = "扫一扫下载安装【巨方助手】，即可免费在线学习、提额、办卡、贷款！"
        let description = ""
        let newsObj = QQApiNewsObject(URL: newsUrl!, title: title, description: description, previewImageData: UIImagePNGRepresentation(UIImage(named: "me_qrcode")!), targetContentType: QQApiURLTargetTypeNews)
        
        let req = SendMessageToQQReq(content: newsObj)
        
        if isToQZone {
            QQApiInterface.SendReqToQZone(req)
        } else {
            QQApiInterface.sendReq(req)
        }
        
    
    }

}
