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
    var refreshControl:UIRefreshControl!
    
    //var leftBarButtonItems: [UIBarButtonItem]?
    var loading = LoadingCircle()
    
    @IBOutlet weak var webContainer: UIView!
    
    var navigationManager : NavigationBarManager!
    var shareView: ShareView!
    
    var showLoading = true
    var isNeedRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tabBarController != nil {
            QL1("title: \( self.tabBarController?.tabBar.items![self.tabBarController!.selectedIndex])")
            self.title = self.tabBarController?.tabBar.items![self.tabBarController!.selectedIndex].title
        }

        url = NSURL(string: ServiceLinkManager.ZixunUrl)!
        if self.title == "签到" {
            url = NSURL(string: ServiceLinkManager.qiandaoUrl)!
        } else if self.title == "已购" {
            showLoading = false
            url = NSURL(string: ServiceLinkManager.yigouUrl)!
            isNeedRefresh = true
        }
        
        navigationManager = NavigationBarManager(self)
         Utils.setNavigationBarAndTableView(self, tableView: nil)
        
        if UIDevice().isX() {
            shareView = ShareView(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 233 - 49 - 32, width: UIScreen.main.bounds.width, height: 233), controller: self)
        } else {
            shareView = ShareView(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 233 - 49 , width: UIScreen.main.bounds.width, height: 233), controller: self)
        }
        
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
    
    @objc func refresh() {
        webView?.reload()
        self.refreshControl.endRefreshing()
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
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let tabbarHegith = self.tabBarController?.tabBar.frame.height;
        QL1("tabbarHegith = \(tabbarHegith!)")
        let fullScreen = UIScreen.main.bounds
        
        var height : CGFloat = 0
        
        if UIDevice().isX() {
            height = fullScreen.height - tabbarHegith! * 2 + 24
        } else {
            height = fullScreen.height - tabbarHegith! * 2
        }
        
        let rect = CGRect(x: fullScreen.origin.x, y: fullScreen.origin.y, width: fullScreen.width, height: height)
        
        
        self.webView = WKWebView(frame: rect, configuration: config)
        
        if isNeedRefresh {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
            webView?.scrollView.addSubview(refreshControl)
        }
        
        self.webContainer.addSubview(self.webView!)
        self.webView?.navigationDelegate = self
        
        let nsurl = NSURL(string: url1!)
        QL1("NSUrl = \(nsurl)")
        let myRequest = NSURLRequest(url: nsurl! as URL);
        //webView.delegate = self
        webView!.load(myRequest as URLRequest);
    }
    
    
    
    /****  webView相关的函数  ***/
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if showLoading {
            loading.show(view: view)
        }
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading.hide()
        QL1("webView.canGoBack = \(webView.canGoBack)")
        
        
        if webView.url != nil {
            QL1("url = \(webView.url!)")
            shareView.shareManager.loadShareInfo(url: webView.url!)
        }
        
        
        if webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton]
        } else {
            navigationItem.leftBarButtonItems = []
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loading.hide()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
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
