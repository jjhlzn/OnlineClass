//
//  WebPageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class UpgradeViewController: BaseUIViewController, UIWebViewDelegate {
    
    var url : NSURL!
    var loginUserStore = LoginUserStore()

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var isForceUpgrade = false

    var loading = LoadingCircle()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isForceUpgrade {
            cancelButton.isEnabled = false
            cancelButton.title = ""
        }
        
        let myRequest = NSURLRequest(url: url as URL);
        webView.delegate = self
        webView.loadRequest(myRequest as URLRequest);
        
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loading.show(view: view)
            }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loading.hide()
        
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        loading.hide()
    }
    
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        checkLoginUser()
    }
    
    private func checkLoginUser() {
        //检查一下是否已经登录，如果登录，则直接进入后面的页面
        let loginUser = loginUserStore.getLoginUser()
        if  loginUser != nil {
            DispatchQueue.main.async { () -> Void in
                self.performSegue(withIdentifier: "hasLoginSegue", sender: self)
            }
        } else {
            DispatchQueue.main.async { () -> Void in
                self.performSegue(withIdentifier: "notLoginSegue", sender: self)
            }
        }
        
    }
    

    
}
