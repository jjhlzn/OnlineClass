//
//  WebPageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class WebPageViewController2: BaseUIViewController, UIWebViewDelegate {
    
    var url : NSURL!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
     //var backButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    var leftBarButtonItems: [UIBarButtonItem]?
    @IBOutlet weak var webView: UIWebView!
    var loading = LoadingCircle()

    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var url1 = url.absoluteString
        url1 = Utils.addUserParams(url1)
        url1 = Utils.addDevcieParam(url1)
        print(url1)
        let myRequest = NSURLRequest(URL: NSURL(string: url1)!);
        webView.delegate = self
        webView.loadRequest(myRequest);
        
        closeButton.target = self
        closeButton.action = #selector(returnLastController)
        
        backButton.target = self
        backButton.action = #selector(webViewBack)
        leftBarButtonItems = navigationItem.leftBarButtonItems

        navigationItem.leftBarButtonItems = [backButton]
        
        addLineBorder(cancelButton)
        shareView.hidden = true
        if title == "提额秘诀" {
            
        } else {
            navigationItem.rightBarButtonItems = []
        }
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loading.show(view)
        if webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton, closeButton]
            backButton.action = #selector(webViewBack)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loading.hide()
        if !webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton]
            backButton.action = #selector(returnLastController)
        }

    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        loading.hide()
    }
    
    
    
    
    func webViewBack() {
        if webView.canGoBack {

            webView.goBack()
            
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
        
        
    }
    
    func returnLastController() {
        navigationController?.popViewControllerAnimated(true)
    }
    
      var shareViewOverlay : UIView!
    @IBAction func shareButtonPressed(sender: AnyObject) {
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

    @IBAction func shareFriendsPressed(sender: AnyObject) {
        print("share to friends")
        share(false)
    }
    
    @IBAction func sharePengyouquanPressed(sender: AnyObject) {
        print("share to pengyouquan")
        share(true)
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        shareView.hidden = true
        shareView.removeFromSuperview()
        view.addSubview(shareView)
        shareViewOverlay.removeFromSuperview()
    }
    
    func addLineBorder(field: UIButton) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, 0, field.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        field.layer.addSublayer(bottomBorder)
    }
    

    
    private func share(isPengyouquan: Bool) {
        let message = WXMediaMessage()
        message.title = "扫一扫下载安装【巨方助手】，即可免费在线学习、提额、办卡、贷款！"
        message.description = "扫一扫下载安装【巨方助手】"
        message.setThumbImage(UIImage(named: "me_qrcode"))
        
        let webPageObject = WXWebpageObject()
        let loginUser = LoginUserStore().getLoginUser()!
        webPageObject.webpageUrl = ServiceLinkManager.ShareTiEMijueUrl + "?userid=\(loginUser.userName!)"
        message.mediaObject = webPageObject
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = (isPengyouquan ? 1 : 0)
        
        WXApi.sendReq(req)
        
        
    }
}
