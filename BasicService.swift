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
                     method: Alamofire.Method = .GET,
                     params: [String: AnyObject]? = [String: AnyObject](),
                     //controller中定义的处理函数
                     completion: (resp: T) -> Void) -> T {
        let serverResponse = T()
        
        Alamofire.request(method, url, parameters: params)
            .responseJSON { response in
                //print("---------------------------------StartRequest---------------------------------")
                //debugPrint(response)
                //print("----------------------------------EndRequest----------------------------------")
                if response.result.isFailure {
                    serverResponse.status = -1
                    serverResponse.errorMessage = "服务器返回出错"
                    completion(resp: serverResponse)
                    
                } else {
                    serverResponse.status = 0
                    serverResponse.parseJSON(params!, json: response.result.value as! NSDictionary)
                    completion(resp: serverResponse)
                }
        }
        
        return serverResponse

    }
    
}


