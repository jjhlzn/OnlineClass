//
//  Service.swift
//  ContractApp
//
//  Created by 刘兆娜 on 16/2/28.
//  Copyright © 2016年 金军航. All rights reserved.
//

import Foundation
import Alamofire


class BasicService {
    
    func sendRequest<T: ServerResponse>(url: String,
                     method: Alamofire.Method = .POST,
                     params: [String: AnyObject]? = [String: AnyObject](),
                     //controller中定义的处理函数
                     completion: (resp: T) -> Void) -> T {
        let serverResponse = T()
        print(url)
        let finalParams = addMoreRequestInfo(params)
        Alamofire.request(method, url, parameters: finalParams)
            .responseJSON { response in
                //print("---------------------------------StartRequest---------------------------------")
                //debugPrint(finalParams)
               // debugPrint(response)
                //print("----------------------------------EndRequest----------------------------------")
                
                if response.result.isFailure {
                    serverResponse.status = -1
                    serverResponse.errorMessage = "服务器返回出错"
                    completion(resp: serverResponse)
                    
                } else {
                    let json = response.result.value as! NSDictionary
                    serverResponse.status = json["status"] as! Int
                    //TODO: 检查status是否是因为token过期，如果是，则需要重新验证token的值, 获得token的值后，重新发送一次请求
                    if serverResponse.status == 0 {
                        serverResponse.parseJSON(params!, json: response.result.value as! NSDictionary)
                    } else {
                        serverResponse.errorMessage = json["errorMessage"] as? String
                    }
                    completion(resp: serverResponse)
                }
        }
        
        return serverResponse
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
    
    private func getUserInfo() -> [String: AnyObject] {
        var userInfo = [String: AnyObject]()
        userInfo["userid"] = ""
        userInfo["token"] = ""
        return userInfo
    }
    
}


