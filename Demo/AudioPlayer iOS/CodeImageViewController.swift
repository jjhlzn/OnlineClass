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
    
    
    
    @IBOutlet weak var codeImageView: UIImageView!
    var qrCodeImageStore: QrCodeImageStore!
    
    var shareManager : ShareManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        /*
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
        
        shareManager = ShareManager(controller: self)
        shareManager.shareDescription = "扫一扫下载安装【巨方助手】，即可免费在线学习、提额、办卡、贷款！"
        
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            print("winxin share is OK")
        } else {
            print("winxin share is  NOT OK")
        }*/
    }
    
    func addLineBorder(field: UIButton) {
        /*
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, 0, field.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        field.layer.addSublayer(bottomBorder)
 */
    }
    

    
    @IBAction func shareToFriends(sender: AnyObject) {
        shareManager.shareToWeixinFriend()
    }

    @IBAction func shareToPengyouquan(sender: AnyObject) {
        shareManager.shareToWeixinPengyouquan()
    }
    
    @IBAction func shareToWeibo(sender: AnyObject) {
        shareManager.shareToWeibo()
    }
    
    @IBAction func shareToQQFriends(sender: AnyObject) {
        shareManager.shareToQQFriend()
    }
    
    
    @IBAction func shareToQzone(sender: AnyObject) {
        shareManager.shareToQzone()
    }
    
    @IBAction func copyLink(sender: AnyObject) {
        shareManager.copyLink()
    }
    
    
}
