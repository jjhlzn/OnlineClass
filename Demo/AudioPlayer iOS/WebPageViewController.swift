//
//  WebPageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class WebPageViewController: BaseUIViewController, UIWebViewDelegate {
    
    var url : NSURL!
    @IBOutlet weak var webView: UIWebView!
    var loading = LoadingCircle()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myRequest = NSURLRequest(URL: url);
        webView.delegate = self
        webView.loadRequest(myRequest);
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loading.show(view)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loading.hide()
    }
    
    func webView(webView: UIWebView,
                   didFailLoadWithError error: NSError?) {
        loading.hide()
    }
    

}
