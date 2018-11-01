//
//  WXApiManager.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 2016/10/8.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import QorumLogs
import SwiftyJSON

class WXApiManager: NSObject, WXApiDelegate {
    /*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
     *
     * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
     * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
     * @param req 具体请求内容，是自动释放的
     */
    
    func onReq(_ req: BaseReq) {
    }
    
    func showLoadingOverlay() {
        let visibleVC = UIApplication.shared.visibleViewController
        QL1(visibleVC)
        if visibleVC is LoginViewController {
            (visibleVC as! LoginViewController).showLoadingOverlay()
        } else if visibleVC is UINavigationController {
            if (visibleVC as! UINavigationController).topViewController is SettingsViewController {
                ((visibleVC as! UINavigationController).topViewController as! SettingsViewController).showLoadingOverlay()
            }
        }
    }
    
    func hideLoadingOverlay() {
        let visibleVC = UIApplication.shared.visibleViewController
        QL1(visibleVC)
        if visibleVC is LoginViewController {
            (visibleVC as! LoginViewController).hideLoadingOverlay()
        } else if visibleVC is UINavigationController {
            if (visibleVC as! UINavigationController).topViewController is SettingsViewController {
                ((visibleVC as! UINavigationController).topViewController as! SettingsViewController).hideLoadingOverlay()
            }
        }
    }
    
    func loginSuccess(_ response: OAuthResponse) {
        let loginUser = LoginUser()
        loginUser.userName = response.userId
        loginUser.password = "loginwithweixin"
        loginUser.name = response.name!
        loginUser.sex = response.sex
        loginUser.codeImageUrl = response.codeImageUrl
        loginUser.token = response.token!
        loginUser.nickName = response.nickName
        loginUser.level = response.level
        loginUser.boss = response.boss
        
        let visibleVC = UIApplication.shared.visibleViewController
        let loginVC = visibleVC as! LoginViewController
        if loginVC.loginUserStore.saveLoginUser(loginUser: loginUser) {
            DispatchQueue.main.async { () -> Void in
                loginVC.performSegue(withIdentifier: "loginSuccessSegue", sender: self)
            }
            
        } else {
            loginVC.displayMessage(message: "登录失败")
        }
    }
    
    func bindSuccess() {
        let visibleVC = UIApplication.shared.visibleViewController
        QL1(visibleVC)
        let settingsVC = (visibleVC as! UINavigationController).topViewController as! SettingsViewController
        
        settingsVC.displayMessage(message: "微信重新绑定成功")
    }
    
    /*! @brief 发送一个sendReq后，收到微信的回应
     *
     * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
     * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
     * @param resp具体的回应内容，是自动释放的
     */
    func onResp(_ resp: BaseResp) {

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
            
       
            let alertView = UIAlertView()
            //alertView.title = "系统提示"
            alertView.message = message
            alertView.addButton(withTitle: "好的")
            alertView.cancelButtonIndex=0
            alertView.show()
            
        } else if (resp is SendAuthResp) {
            let authResp = resp as! SendAuthResp
            if authResp.errCode == 0 {
                let code = authResp.code
                
                fetchWeixinToken(code ?? "")
            }
        }

    }
    
    func fetchWeixinToken(_ code: String) {
        let getWeixinTokenReq = GetWeixinTokenRequest()
        getWeixinTokenReq.code = code
        showLoadingOverlay()
        BasicService().sendRequest(url: ServiceConfiguration.GET_WEIXIN_TOKEN, request: getWeixinTokenReq) {
            (resp: GetWeixinTokenResonse) -> Void in
            if resp.status != ServerResponseStatus.Success.rawValue {
                QL4("server return error: \(resp.errorMessage!)")
                self.hideLoadingOverlay()
                return
            }
            
            let respStr = resp.responseString
            QL1(respStr)
            
            let loginUserStroe = LoginUserStore()
            if loginUserStroe.getLoginUser() != nil {
                self.sendBindWeixinRequest(respStr)
            } else {
                self.sendOAuthRequest(respStr)
            }
        }
        
    }
    
    func sendOAuthRequest(_ respStr: String) {
        let j = JSON(parseJSON: respStr)
        
        if j["access_token"].stringValue != "" {
            let access_token = j["access_token"].stringValue
            let openid = j["openid"].stringValue
            let unionid = j["unionid"].stringValue
            let refresgToken = j["refresh_token"].stringValue
            
            let oauthReq = OAuthRequest()
            oauthReq.openId = openid
            oauthReq.unionId = unionid
            oauthReq.accessToken = access_token
            oauthReq.refreshToken = refresgToken
            oauthReq.respStr = respStr
            oauthReq.deviceToken = (UIApplication.shared.delegate as! AppDelegate).deviceTokenString
            
            BasicService().sendRequest(url: ServiceConfiguration.OAUTH, request: oauthReq) {
                (response: OAuthResponse) -> Void in
                if response.status != ServerResponseStatus.Success.rawValue {
                    QL4("server return error: \(response.errorMessage!)")
                    self.hideLoadingOverlay()
                    return
                }
                 self.hideLoadingOverlay()
                self.loginSuccess(response)
               
            }
            
        } else {
            self.hideLoadingOverlay()
            QL4("微信登录出错了")
        }
        
        
    }
    
    func sendBindWeixinRequest(_ respStr : String) {
        let j = JSON(parseJSON: respStr)
        
        if j["access_token"].stringValue != "" {
            let access_token = j["access_token"].stringValue
            let openid = j["openid"].stringValue
            let unionid = j["unionid"].stringValue
            let refresgToken = j["refresh_token"].stringValue
            
            let req = BindWeixinRequest()
            req.openId = openid
            req.unionId = unionid
            req.accessToken = access_token
            req.refreshToken = refresgToken
            req.respStr = respStr
            req.deviceToken = (UIApplication.shared.delegate as! AppDelegate).deviceTokenString
            
            BasicService().sendRequest(url: ServiceConfiguration.BIND_WEIXIN, request: req) {
                (response: OAuthResponse) -> Void in
                if response.status != ServerResponseStatus.Success.rawValue {
                    QL4("server return error: \(response.errorMessage!)")
                    self.hideLoadingOverlay()
                    return
                }
                self.hideLoadingOverlay()
                self.bindSuccess()
                
            }
            
        } else {
            self.hideLoadingOverlay()
            QL4("微信绑定出错了")
        }
    }
}

