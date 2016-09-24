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


class ApplyBrowserController : IapSupportWebPageViewController, WKNavigationDelegate {
    
    var url : NSURL!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var backButtonCopy: UIBarButtonItem!
    
    //var leftBarButtonItems: [UIBarButtonItem]?
    var loading = LoadingCircle()
    
    @IBOutlet weak var webContainer: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "申请"
        url = NSURL(string: ServiceLinkManager.ApplyUrl)!
        
        initIAP()
        initWebView()

        
        backButton.target = self
        backButton.action = #selector(webViewBack)
        backButtonCopy = backButton
        navigationItem.leftBarButtonItems = []
        
        //navigationItem.leftBarButtonItems = [backButton]
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    let contentController = WKUserContentController()
    private func initWebView() {
        var url1 = url.absoluteString
        url1 = Utils.addUserParams(url1)
        url1 = Utils.addDevcieParam(url1)
        print(url1)
        
        contentController.addScriptMessageHandler(
            self,
            name: "payCallbackHandler"
        )
        
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
            navigationItem.leftBarButtonItems = [backButton]
        } else {
            navigationItem.leftBarButtonItems = []
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        loading.hide()
        QL1("webView.canGoBack = \(webView.canGoBack)")
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
        } else {
            navigationItem.leftBarButtonItems = []
        }
    }
    
    
}