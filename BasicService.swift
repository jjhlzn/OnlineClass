//
//  Service.swift
//  ContractApp
//
//  Created by 刘兆娜 on 16/2/28.
//  Copyright © 2016年 金军航. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import QorumLogs


class BasicService {
    
    private func sendRequest<T: ServerResponse>(url: String,
                     method: Alamofire.Method = .POST,
                     serverRequest: ServerRequest,
                     params: [String: AnyObject]? = [String: AnyObject](),
                     hasResendForTokenInvalid: Bool = false,
                     //controller中定义的处理函数
                     completion: (resp: T) -> Void) -> T {
        let serverResponse = T()
        QL1(url)
        let finalParams = addMoreRequestInfo(params)
        
        let request = NSMutableURLRequest(URL: NSURL( string: url)!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        do {
            request.HTTPBody = try JSON(finalParams).rawData()
            
            
        } catch let error {
            QL4("catchException, ex = \(error)")
            serverResponse.status = -1
            serverResponse.errorMessage = "客户端错误，解析Request出错"
            return serverResponse
        }
        
        Alamofire.request(request)
            .responseJSON { response in
                //print("---------------------------------StartRequest---------------------------------")
                //debugPrint(finalParams)
                //debugPrint(response)
                //print("----------------------------------EndRequest----------------------------------")
                
                if response.result.isFailure {
                    serverResponse.status = -1
                    serverResponse.errorMessage = "服务器返回出错"
                    completion(resp: serverResponse)
                    
                } else {
                    let json = response.result.value as! NSDictionary
                    serverResponse.status = json["status"] as! Int
                    //检查status是否是因为token过期，如果是，则需要重新验证token的值, 获得token的值后，重新发送一次请求
                    if serverResponse.status == ServerResponseStatus.TokenInvalid.rawValue && !hasResendForTokenInvalid {
                        var loginUser = LoginUserStore().getLoginUser()
                        if (loginUser != nil) {
                            let updateTokenReq = UpdateTokenRequest(userName: loginUser!.userName!, password: loginUser!.password!)
                            let fatherCompletion = completion
                            let fatherUrl = url
                            let fatherRequest = serverRequest
                            self.sendRequest(ServiceConfiguration.UPDATE_TOKEN, serverRequest: updateTokenReq, hasResendForTokenInvalid: true) {
                                (updateTokenResp : UpdateTokenResponse) -> Void in
                                QL1("handle update token response")
                                if updateTokenResp.status != 0  {
                                    serverResponse.errorMessage = "登录已过期，请重新登录"
                                    fatherCompletion(resp: serverResponse)
                                    return
                                }
                                
                                //保存token
                                loginUser = LoginUserStore().getLoginUser()
                                QL1(loginUser)
                                loginUser!.token = updateTokenResp.token
                                QL1("set token")
                                if !LoginUserStore().updateLoginUser() {
                                    serverResponse.errorMessage = "登录已过期，请重新登录"
                                    fatherCompletion(resp: serverResponse)
                                    return
                                }
                                
                                //重新发送请求
                                QL1("重新发送请求")
                                QL1(fatherRequest)
                                fatherRequest.test = "resend"
                                self.sendRequest(fatherUrl, serverRequest: fatherRequest, params: fatherRequest.params, hasResendForTokenInvalid: true, completion: fatherCompletion)
                            }
                        }
                    }
                    
                    if serverResponse.status == 0 {
                        serverResponse.parseJSON(serverRequest, json: response.result.value as! NSDictionary)
                        completion(resp: serverResponse)
                    } else if serverResponse.status == ServerResponseStatus.TokenInvalid.rawValue {
                        //在上面的代理处理，推迟resp处理
                        QL1("handle invalid token")
                        if hasResendForTokenInvalid {
                            serverResponse.errorMessage = "请重新登录"
                            completion(resp: serverResponse)
                        }
                    } else  {
                        serverResponse.errorMessage = json["errorMessage"] as? String
                        completion(resp: serverResponse)
                    }
                }
        }
        
        return serverResponse
    }
    
    func sendRequest<T: ServerResponse>(url: String,
                     request: ServerRequest,
                     method: Alamofire.Method = .POST,
                     //controller中定义的处理函数
        completion: (resp: T) -> Void) -> T {
        return sendRequest(url, method: method, serverRequest: request, params: request.params, completion: completion)
    }
    
    private func addMoreRequestInfo(params: [String: AnyObject]?) -> [String: AnyObject] {
        var newParams = [String: AnyObject]()
        newParams["request"] = params
        newParams["client"] = getClientInfo()
        newParams["userInfo"] = getUserInfo()
        return newParams
        
    }
    
    private func getClientInfo() -> [String: AnyObject]{
        var clientInfo = [String: AnyObject]()
        clientInfo["platform"] = "iphone"
        clientInfo["model"] = UIDevice.currentDevice().model
        clientInfo["osversion"] = UIDevice.currentDevice().systemVersion
        
        let screensize = UIScreen.mainScreen().bounds
        clientInfo["screensize"] = "\(screensize.width)*\(screensize.height)"
        
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let appBundle = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        clientInfo["appversion"] = "\(version).\(appBundle)"
        
        return clientInfo
        
    }
    
    var loginUserStore = LoginUserStore()
    private func getUserInfo() -> [String: AnyObject] {
        var userInfo = [String: AnyObject]()
        let loginUser = loginUserStore.getLoginUser()
        userInfo["userid"] = loginUser?.userName!
        userInfo["token"] = loginUser?.token!
        return userInfo
    }
    
}


