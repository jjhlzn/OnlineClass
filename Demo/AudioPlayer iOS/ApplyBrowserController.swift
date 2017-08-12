//
//  ApplyBrowserController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 2016/9/24.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import WebKit
import StoreKit
import QorumLogs
import Alamofire
import Kanna


class ApplyBrowserController : IapSupportWebPageViewController, WKNavigationDelegate {
    
    var url : NSURL!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var backButtonCopy: UIBarButtonItem!
    
    //var leftBarButtonItems: [UIBarButtonItem]?
    var loading = LoadingCircle()
    
    @IBOutlet weak var webContainer: UIView!
    
    
    var overlay = UIView()
    var shareManager : ShareManager!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var closeShareViewButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "申请"
        url = NSURL(string: ServiceLinkManager.ShenqingUrl)!
        
        
        initIAP()
        initWebView()

        overlay.hidden = true
        
        backButton.target = self
        backButton.action = #selector(webViewBack)
        //建立一个后退button的拷贝，不然执行下面这条语句后，backButton会被设置为nil
        backButtonCopy = backButton
        navigationItem.leftBarButtonItems = []
        
        //navigationItem.leftBarButtonItems = [backButton]
        //设置分享相关
        shareView.hidden = true
        shareManager = ShareManager(controller: self)
        closeShareViewButton.addBorder(viewBorder.Top, color: UIColor(white: 0.65, alpha: 0.5), width: 1)

        shareManager.isUseQrImage = false
        
        shareManager.loadShareInfo(url)
        
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
        
        let tabbarHegith = self.tabBarController?.tabBar.frame.height;
        QL1("tabbarHegith = \(tabbarHegith!)")
        let fullScreen = UIScreen.mainScreen().bounds
        let rect = CGRect(x: fullScreen.origin.x, y: fullScreen.origin.y, width: fullScreen.width, height: fullScreen.height - tabbarHegith! * 2)
        self.webView = WKWebView(frame: rect, configuration: config)
        
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
        
        if webView.URL != nil {
            QL1("url = \(webView.URL!)")
            shareManager.loadShareInfo(webView.URL!)
        }
        
        if webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton]
        } else {
            navigationItem.leftBarButtonItems = []
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        loading.hide()
        QL1("webView.canGoBack = \(webView.canGoBack)")
        
        if webView.URL != nil {
            QL1("url = \(webView.URL!)")
            shareManager.loadShareInfo(webView.URL!)
        }
        if webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton]
        } else {
            navigationItem.leftBarButtonItems = []
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
            if webView!.URL != nil {
                QL1("url = \(webView!.URL!)")
                shareManager.loadShareInfo(webView!.URL!)
            }
        } else {
            navigationItem.leftBarButtonItems = []
        }
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        //如果正在评论，关闭评论的窗口
        if overlay.hidden {
            shareView.becomeFirstResponder()
            showShareView()
        } else {
            hideShareView()
        }
    }
    
    var shareViewHasCreated = false;
    func showShareView() {
        if !shareViewHasCreated {
            let navHeight = self.navigationController?.navigationBar.frame.height;
            
            let fullScreen = UIScreen.mainScreen().bounds
            let rect = CGRect(x: fullScreen.origin.x, y: fullScreen.origin.y + navHeight!, width: fullScreen.width, height: fullScreen.height)
            
            print("showOverlay")

            overlay = UIView(frame: rect)
            overlay.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
            shareView.removeFromSuperview()
            shareView.hidden = false
            overlay.addSubview(shareView)
            self.view.addSubview(overlay)
            shareViewHasCreated = true
        
        }
        overlay.hidden = false
        
    }
    
    func hideShareView() {
        print("hideOverlay")
        /*
        shareView.removeFromSuperview()
        self.view.addSubview(shareView)
        shareView.hidden = true
        overlay.removeFromSuperview()*/
        overlay.hidden = true
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