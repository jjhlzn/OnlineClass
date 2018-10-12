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
//import SwiftyBeaver


class BasicService {
    
    @discardableResult
    private func sendRequest0<T: ServerResponse>(url: String,
                     method: Alamofire.HTTPMethod = Alamofire.HTTPMethod.post,
                     serverRequest: ServerRequest,
                     params: [String: AnyObject]? = [String: AnyObject](),
                     hasResendForTokenInvalid: Bool = false,
                     timeout: TimeInterval = 5,
                     //controller中定义的处理函数
        completion: @escaping (_ resp: T) -> Void) -> T {
        let serverResponse = T()
        QL1(url)
        
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try serverRequest.getJSON().rawData()
            //QL1(serverRequest.getJSON())
        } catch let error {
            QL4("catchException, ex = \(error)")
            serverResponse.status = -1
            serverResponse.errorMessage = "您的网络不给力，请检查网络是否正常"
            return serverResponse
        }
        Alamofire.request(request)
        //Alamofire.request(url, method: method, parameters: serverRequest.params, encoding: JSONEncoding.default)
            .responseJSON { response in
                //print("---------------------------------StartRequest---------------------------------")
                //debugPrint(response)
                
                //print("----------------------------------EndRequest----------------------------------")
                
                if response.result.isFailure {
                    QL4("服务器出错了")
                    serverResponse.status = -1
                    serverResponse.errorMessage = "您的网络不给力，请检查网络是否正常"
                    completion(serverResponse)
                    
                } else {
                    let json = response.result.value as! NSDictionary
                    //QL1(json)
                    serverResponse.status = json["status"] as! Int
                    //检查status是否是因为token过期，如果是，则需要重新验证token的值, 获得token的值后，重新发送一次请求
                    if serverResponse.status == ServerResponseStatus.TokenInvalid.rawValue && !hasResendForTokenInvalid {
                        var loginUser = LoginUserStore().getLoginUser()
                        if (loginUser != nil) {
                            let updateTokenReq = UpdateTokenRequest(userName: loginUser!.userName!, password: loginUser!.password!)
                            let fatherCompletion = completion
                            let fatherUrl = url
                            let fatherRequest = serverRequest
                            self.sendRequest(url: ServiceConfiguration.UPDATE_TOKEN, request: updateTokenReq, timeout: timeout) {
                                (updateTokenResp : UpdateTokenResponse) -> Void in
                                QL1("handle update token response")
                                if updateTokenResp.status != 0  {
                                    serverResponse.errorMessage = "登录已过期，请重新登录"
                                    fatherCompletion(serverResponse)
                                    return
                                }
                                
                                //保存token
                                loginUser = LoginUserStore().getLoginUser()
                                QL1(loginUser)
                                loginUser!.token = updateTokenResp.token
                                QL1("set token")
                                if !LoginUserStore().updateLoginUser() {
                                    serverResponse.errorMessage = "登录已过期，请重新登录"
                                    fatherCompletion(serverResponse)
                                    return
                                }
                                
                                //重新发送请求
                                QL1("重新发送请求")
                                QL1(fatherRequest)
                                fatherRequest.test = "resend"
                                self.sendRequest0(url: fatherUrl, serverRequest: fatherRequest, params: fatherRequest.params, timeout: timeout, completion: fatherCompletion)
                            }
                        }
                    }
                    
                    if serverResponse.status == 0 {
                        serverResponse.parseJSON(request: serverRequest, json: response.result.value as! NSDictionary)
                        completion(serverResponse)
                    } else if serverResponse.status == ServerResponseStatus.TokenInvalid.rawValue {
                        //在上面的代理处理，推迟resp处理
                        QL1("handle invalid token")
                        if hasResendForTokenInvalid {
                            serverResponse.errorMessage = "请重新登录"
                            completion(serverResponse)
                        }
                    } else  {
                        serverResponse.errorMessage = json["errorMessage"] as? String
                        completion(serverResponse)
                    }
                }
        }
        
        return serverResponse
    }
    
    @discardableResult
    func sendRequest<T: ServerResponse>(url: String,
                     request: ServerRequest,
                     timeout: TimeInterval = 5,
                     method: Alamofire.HTTPMethod = Alamofire.HTTPMethod.post,
                     //controller中定义的处理函数
        completion: @escaping (_ resp: T) -> Void) -> T {
        return sendRequest0(url: url, method: method, serverRequest: request, params: request.params, timeout: timeout, completion: completion)
    }
    
    
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    func uploadImageRequest(url:String, parameters:Dictionary<String, String>, imageData:NSData)  {
         //return (URLRequestConvertible(), nil)
        /*
        ///////
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append(imageData as Data)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
        }
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
 
 */
    }
    

    
}


