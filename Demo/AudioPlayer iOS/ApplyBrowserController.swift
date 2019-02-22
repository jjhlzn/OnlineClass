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
import MJRefresh
//import Kanna

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}

class ApplyBrowserController : IapSupportWebPageViewController, WKNavigationDelegate {
    
    var url : NSURL!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var backButtonCopy: UIBarButtonItem!
    //var refreshControl:UIRefreshControl!
    let refreshHeader = MJRefreshNormalHeader()
    
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
            self.title = self.tabBarController?.tabBar.items![self.tabBarController!.selectedIndex].title
        }

        url = NSURL(string: ServiceLinkManager.ZixunUrl)!
        if self.title == "签到" {
            url = NSURL(string: ServiceLinkManager.qiandaoUrl)!
             isNeedRefresh = true
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
        if self.title == "已购" {
            let url1 = makeUrl()
            let nsurl = NSURL(string: url1)
            let myRequest = NSURLRequest(url: nsurl! as URL);
            //webView.delegate = self
            webView!.load(myRequest as URLRequest)
            
        } else {
            
            webView?.reload()
        
        }
        self.refreshHeader.endRefreshing()
    }
    
    
    func reloadQiandaoPageIfNeeded() {
         if self.title == "签到" && LoginManager.Refresh_Qiandao_After_Login {
            LoginManager.Refresh_Qiandao_After_Login = false
            let url1 = makeUrl()
            let nsurl = NSURL(string: url1)
            let myRequest = NSURLRequest(url: nsurl! as URL);
            //webView.delegate = self
            webView!.load(myRequest as URLRequest);
        }
    }
    
    func reloadYigouPageIfNeeded() {
        if self.title == "已购" && LoginManager.Refresh_Yigou_After_Login {
            LoginManager.Refresh_Yigou_After_Login = false
            let url1 = makeUrl()
            let nsurl = NSURL(string: url1)
            let myRequest = NSURLRequest(url: nsurl! as URL);
            //webView.delegate = self
            webView!.load(myRequest as URLRequest);
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadYigouPageIfNeeded()
        reloadQiandaoPageIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func makeUrl() -> String {
        var url1 = url.absoluteString
        url1 = Utils.addUserParams(url: url1!)
        url1 = Utils.addDevcieParam(url: url1!)
        url1 = Utils.addBuyInfo(url: url1!)
        url1 = url1! + "&abc=\(Date().ticks)"
        return url1!
    }
    
    
    override func initWebView() {
        super.initWebView()
        
        var url1 = makeUrl()
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let tabbarHegith = self.tabBarController?.tabBar.frame.height;
        //QL1("tabbarHegith = \(tabbarHegith!)")
        let fullScreen = UIScreen.main.bounds
        
        var height : CGFloat = 0
        
        if UIDevice().isX() {
            height = fullScreen.height - tabbarHegith! * 2  + 24
        } else {
            height = fullScreen.height - tabbarHegith! * 2
        }
        
        let rect = CGRect(x: fullScreen.origin.x, y: fullScreen.origin.y, width: fullScreen.width, height: height)
        
        
        self.webView = WKWebView(frame: rect, configuration: config)
        
        if isNeedRefresh {
            refreshHeader.setRefreshingTarget(self, refreshingAction: #selector(refresh))
            webView?.scrollView.mj_header = refreshHeader
            refreshHeader.lastUpdatedTimeLabel.isHidden = true
            refreshHeader.stateLabel.isHidden = true
        }
        
        self.webContainer.addSubview(self.webView!)
        self.webView?.navigationDelegate = self
        
        let nsurl = NSURL(string: url1)
        let myRequest = NSURLRequest(url: nsurl! as URL);
        //webView.delegate = self
        webView!.load(myRequest as URLRequest);
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if navigationAction.request.url?.scheme == "tel" {
            
            UIApplication.shared.openURL(navigationAction.request.url!)
            //UIApplication.shared.openURL(URL(string: "tel://13706794299")!)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    /****  webView相关的函数  ***/
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if showLoading {
            loading.show(view: view)
        }
        //QL1("webView.canGoBack = \(webView.canGoBack)")
        
        if webView.url != nil {
            //QL1("url = \(webView.url!)")
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
        //QL1("webView.canGoBack = \(webView.canGoBack)")
        
        
        if webView.url != nil {
            //QL1("url = \(webView.url!)")
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
