//
//  Service.swift
//  ContractApp
//
//  Created by 刘兆娜 on 16/2/28.
//  Copyright © 2016年 金军航. All rights reserved.
//

import Foundation

enum HttpMethod {
    case Get
    case Post
}

class BasicService {
    func sendRequest<T: ServerResponse>(url: String, completion: (resp: T) -> Void, responseHandler: (resp: T, dict: NSDictionary) -> Void) -> T {
        return sendRequest0(HttpMethod.Get, url: url, postString: "", completion: completion, responseHandler: responseHandler);
    }
    
    
    func postRequest<T: ServerResponse>(url: String, postString: String, completion: (resp: T) -> Void, responseHandler: (resp: T, dict: NSDictionary) -> Void) -> T {
        return sendRequest0(HttpMethod.Post, url: url, postString: postString, completion: completion, responseHandler: responseHandler);
    }
    
    private func sendRequest0<T: ServerResponse>(method: HttpMethod, url: String, postString: String, completion: (resp: T) -> Void, responseHandler: (resp: T, dict: NSDictionary) -> Void) -> T {
        let serverResponse = T()
        // Setup the session to make REST GET call.  Notice the URL is https NOT http!!
        let postEndpoint: String = url
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: postEndpoint)!
        print("send url: \(url)")
        // Make the POST call and handle it in a completion handler
        
        let request = NSMutableURLRequest(URL: NSURL(string: postEndpoint)!)
        if method == HttpMethod.Post {
            request.HTTPMethod = "POST"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print(url)
                    print("Not a 200 response")
                    serverResponse.status = -1
                    serverResponse.errorMessage = "服务器返回出错"
                    completion(resp: serverResponse)
                    return
            }
            
            // Read the JSON
            do {
                if let ipString = NSString(data:data!, encoding: NSUTF8StringEncoding) {
                    // Print what we got from the call
                    print(ipString)
                    
                    let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    serverResponse.status = dict["status"] as! Int
                    if  serverResponse.status !=  0 {
                        return
                    }
                    
                    responseHandler(resp: serverResponse, dict: dict)
                    completion(resp: serverResponse)
                }
            } catch {
                print("bad things happened")
                serverResponse.status = -1
                serverResponse.errorMessage = "服务器结果处理异常"
                completion(resp: serverResponse)
                return
            }
        }).resume()
        
        return serverResponse
    }

}


