//
//  WeixinLoginManager.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/10/20.
//  Copyright © 2018 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs

class WeixinLoginManager  {

    func loginStep1() {
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = ""
        
        if !WXApi.send(req) {
            QL4("weixin sendreq failed")
        }
    }

    func bindWeixin() {
        loginStep1() 
    }
}
