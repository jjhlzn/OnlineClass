//
//  StartupViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/6.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class StartupViewController: UIViewController {
    
    var loginUserStore = LoginUserStore()
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
