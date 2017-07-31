//
//  WebPageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import WebKit
import StoreKit
import QorumLogs

class WebPageViewController: IapSupportWebPageViewController, WKNavigationDelegate {
    
    var url : NSURL!
    var isBackToMainController = false
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var canShowCloseButton = true
    //var backButton: UIBarButtonItem!
    
    var loginUserStore = LoginUserStore()
    
    var leftBarButtonItems: [UIBarButtonItem]?
    
    @IBOutlet weak var webContainer: UIView!
    var loading = LoadingCircle()
    
    

    var overlay = UIView()
    var shareManager : ShareManager!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var closeShareViewButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        initIAP()
        initWebView()
        
        closeButton.target = self
        closeButton.action = #selector(returnLastController)
        
        backButton.target = self
        backButton.action = #selector(webViewBack)
        leftBarButtonItems = navigationItem.leftBarButtonItems
        
        
        navigationItem.leftBarButtonItems = [backButton]

        if title == "提额秘诀" {
            
        } else {
            //navigationItem.rightBarButtonItems = []
        }
        
        
        //设置分享相关
        shareView.hidden = true
        shareManager = ShareManager(controller: self)
        closeShareViewButton.addBorder(viewBorder.Top, color: UIColor(white: 0.65, alpha: 0.5), width: 1)
        shareManager.shareTitle = "test"
        shareManager.shareUrl = "http://www.baidu.com"
        shareManager.isUseQrImage = false
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func initWebView() {
        super.initWebView()
        var url1 = url.absoluteString
        url1 = Utils.addUserParams(url1)
        url1 = Utils.addDevcieParam(url1)
        print(url1)
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        
        self.webContainer.addSubview(self.webView!)
        self.webView?.navigationDelegate = self
        
        let nsurl = NSURL(string: url1)
        QL1("NSUrl = \(nsurl)")
        let myRequest = NSURLRequest(URL: nsurl!);
        //webView.delegate = self
        webView!.loadRequest(myRequest);
    }
    
    
    
    /****  webView相关的函数  ***/
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        loading.show(view)
        QL1("webView.canGoBack = \(webView.canGoBack)")
        if webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton, closeButton]
            backButton.action = #selector(webViewBack)
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        loading.hide()
        QL1("webView.canGoBack = \(webView.canGoBack)")
        if !webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton]
            backButton.action = #selector(returnLastController)
        }
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        loading.hide()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        loading.hide()
    }
    
    
    func webViewBack() {
        if webView!.canGoBack {
            webView!.goBack()
            
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    private func checkLoginUser() {
        
        //检查一下是否已经登录，如果登录，则直接进入后面的页面
        let loginUser = loginUserStore.getLoginUser()
        if  loginUser != nil {
            QL1("found login user")
            QL1("userid = \(loginUser?.userName), password = \(loginUser?.password), token = \(loginUser?.token)")
            self.performSegueWithIdentifier("hasLoginSegue", sender: self)
        } else {
            QL1("no login user")
            self.performSegueWithIdentifier("notLoginSegue", sender: self)
        }
        
    }
    
    
    func returnLastController() {
        /*
         var controllers = navigationController?.viewControllers
         if controllers?.count >= 2 {
         let top = controllers![1] as? AlbumListController
         if top != nil {
         controllers?.removeLast(2)
         navigationController?.setViewControllers(controllers!, animated: true)
         return
         }
         }*/
        if isBackToMainController {
            checkLoginUser()
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    
    
    /******************* 分享 *************************************************/

    @IBAction func shareButtonPressed(sender: AnyObject) {
        //如果正在评论，关闭评论的窗口
        QL1("shareButton Pressed")
        
        if shareView.hidden {
            shareView.becomeFirstResponder()
            showShareView()
        } else {
            hideShareView()
        }
    }
    
    func showShareView() {
        print("showOverlay")
        overlay = UIView(frame: UIScreen.mainScreen().bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
        shareView.removeFromSuperview()
        shareView.hidden = false
        overlay.addSubview(shareView)
        self.view.addSubview(overlay)
    }
    
    func hideShareView() {
        print("hideOverlay")
        shareView.removeFromSuperview()
        self.view.addSubview(shareView)
        shareView.hidden = true
        overlay.removeFromSuperview()
    }
    
    
    @IBAction func closeShareViewButtonPressed(sender: AnyObject) {
        hideShareView()
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
