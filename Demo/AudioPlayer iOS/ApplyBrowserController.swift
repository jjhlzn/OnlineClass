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
//import Kanna


class ApplyBrowserController : IapSupportWebPageViewController, WKNavigationDelegate {
    
    var url : NSURL!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var backButtonCopy: UIBarButtonItem!
    
    //var leftBarButtonItems: [UIBarButtonItem]?
    var loading = LoadingCircle()
    
    @IBOutlet weak var webContainer: UIView!
    
    var navigationManager : NavigationBarManager!
    var shareView: ShareView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "资讯"
        url = NSURL(string: ServiceLinkManager.ZixunUrl)!
        
        navigationManager = NavigationBarManager(self)
        shareView = ShareView(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 233 - 49, width: UIScreen.main.bounds.width, height: 233), controller: self)
        navigationManager.shareView = shareView
        
        initIAP()
        initWebView()

       
        
        backButton.target = self
        backButton.action = #selector(webViewBack)
        //建立一个后退button的拷贝，不然执行下面这条语句后，backButton会被设置为nil
        backButtonCopy = backButton
        navigationItem.leftBarButtonItems = []
        
        navigationItem.rightBarButtonItems = []
        navigationManager.setMusicButton()
        navigationManager.setShareButton()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func initWebView() {
        super.initWebView()
        
        var url1 = url.absoluteString
        url1 = Utils.addUserParams(url: url1!)
        url1 = Utils.addDevcieParam(url: url1!)
        print(url1)

        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let tabbarHegith = self.tabBarController?.tabBar.frame.height;
        QL1("tabbarHegith = \(tabbarHegith!)")
        let fullScreen = UIScreen.main.bounds
        let rect = CGRect(x: fullScreen.origin.x, y: fullScreen.origin.y, width: fullScreen.width, height: fullScreen.height - tabbarHegith! * 2)
        self.webView = WKWebView(frame: rect, configuration: config)
        
        self.webContainer.addSubview(self.webView!)
        self.webView?.navigationDelegate = self
        
        let nsurl = NSURL(string: url1!)
        QL1("NSUrl = \(nsurl)")
        let myRequest = NSURLRequest(url: nsurl! as URL);
        //webView.delegate = self
        webView!.load(myRequest as URLRequest);
    }
    
    
    
    /****  webView相关的函数  ***/
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        loading.show(view: view)
        QL1("webView.canGoBack = \(webView.canGoBack)")
        
        if webView.url != nil {
            QL1("url = \(webView.url!)")
            shareView.setShareUrl((webView.url?.absoluteString)!)
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
        
        /*
        if webView.URL != nil {
            QL1("url = \(webView.URL!)")
            shareManager.loadShareInfo(webView.URL!)
        }*/
        
        
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
    
    
    @objc func webViewBack() {
        if webView!.canGoBack {
            webView!.goBack()
            if webView!.url != nil {
                QL1("url = \(webView!.url!)")
                shareView.setShareUrl((webView?.url?.absoluteString)!)
            }
        } else {
            navigationItem.leftBarButtonItems = []
        }
    }
    
    
}
