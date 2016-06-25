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
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
     //var backButton: UIBarButtonItem!
    
    var leftBarButtonItems: [UIBarButtonItem]?
    @IBOutlet weak var webView: UIWebView!
    var loading = LoadingCircle()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var url1 = url.absoluteString
        url1 = Utils.addUserParams(url1)
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
    

}
