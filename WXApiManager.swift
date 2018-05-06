//
//  WXApiManager.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 2016/10/8.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import QorumLogs


class WXApiManager: NSObject, WXApiDelegate {
    /*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
     *
     * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
     * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
     * @param req 具体请求内容，是自动释放的
     */
    func onReq(req: BaseReq) {
        
    }
    
    
    
    /*! @brief 发送一个sendReq后，收到微信的回应
     *
     * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
     * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
     * @param resp具体的回应内容，是自动释放的
     */
    func onResp(resp: BaseResp) {
        if resp is PayResp {
            //支付返回结果，实际支付结果需要去微信服务器端查询
            var message = ""
            switch (resp.errCode) {
            case WXSuccess.rawValue:
                message = "支付成功"
                QL1("支付成功－PaySuccess，retcode = \(resp.errCode)");
                break;
                
            default:
                message = "支付失败"
                QL1("错误，retcode = \(resp.errCode), retstr = \(resp.errStr)");
                break;
            }
            
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release]; */
            let alertView = UIAlertView()
            //alertView.title = "系统提示"
            alertView.message = message
            alertView.addButton(withTitle: "好的")
            alertView.cancelButtonIndex=0
            alertView.show()
            
        }

    }
}
