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
            cancelButton.enabled = false
            cancelButton.title = ""
        }
        
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
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        loading.hide()
    }
    
    
    
    func returnLastController() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "startupSegue" {
            let dest = segue.destinationViewController as! StartupViewController
            dest.isSkipUpgradeCheck = true
        }
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        checkLoginUser()
    }
    
    private func checkLoginUser() {
        //检查一下是否已经登录，如果登录，则直接进入后面的页面
        let loginUser = loginUserStore.getLoginUser()
        if  loginUser != nil {
            print("found login user")
            print("userid = \(loginUser?.userName), password = \(loginUser?.password), token = \(loginUser?.token)")
            self.performSegueWithIdentifier("hasLoginSegue", sender: self)
        } else {
            print("no login user")
            self.performSegueWithIdentifier("notLoginSegue", sender: self)
        }
        
    }
    

    
}
