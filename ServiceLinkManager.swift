//
//  ServiceLinkManager.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/28.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation


class ServiceLinkManager {
    static let host = "114.215.236.171"
    static let port = "6012"
    
    
    static var MyTuiJianUrl : String {
        get {
            return "http://\(host):\(port)/Center/MyTuiJian"
        }
    }
    
    static var MyOrderUrl : String {
        get {
            return "http://\(host):\(port)/Center/MyOrder"
        }
    }
    
    static var MyAgentUrl : String {
        get {
            return "http://\(host):\(port)/Center/MyAgent"
        }
    }
    
    static var MyExchangeUrl : String {
        get {
            return "http://\(host):\(port)/Center/MyExchange"
        }
    }
    
    static var MyTeamUrl : String {
        get {
            return "http://\(host):\(port)/Center/MyTeam"
        }
    }
    
    static var FunctionCardManagerUrl : String {
        get {
            return "http://\(host):\(port)/Service/CardManage"
        }
    }
    
    static var FunctionCustomerServiceUrl : String {
        get {
            return "http://\(host):\(port)/Service/Custom"
        }
    }

    
    static var FunctionUpUrl : String {
        get {
            return "http://\(host):\(port)/Service/CreditLines"
        }
    }
    
    static var FunctionFastCardUrl : String {
        get {
            return "http://\(host):\(port)/Service/FastCard"
        }
    }
    
    static var FunctionCreditSearchUrl : String {
        get {
            return "http://\(host):\(port)/Service/Ipcrs"
        }
    }
    
    
    static var FunctionMccSearchUrl : String {
        get {
            return "http://\(host):\(port)/Service/MccSearch"
        }
    }
    
}