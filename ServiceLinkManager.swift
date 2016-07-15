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
    
    static var FunctionJiaoFeiUrl : String {
        get {
            return "http://\(host):\(port)/Service/Fee"
        }
    }
    
    static var FunctionDaiKuangUrl : String {
        get {
            return "http://\(host):\(port)/Service/Loan"
        }
    }
    
    static var FunctionCarLoanUrl : String {
        get {
            return "http://\(host):\(port)/Service/CarLoan"
        }
    }
    
    static var FunctionShopUrl : String {
        get {
            return "http://\(host):\(port)/shop/shopindex"
        }
    }
    
    static var ShareQrImageUrl : String {
        get {
            return "http://\(host):\(port)/Center/MyLink.aspx";
        }
    }
    
    static var ShareTiEMijueUrl : String {
        get {
            return "http://\(host):\(port)/Center/MyLink.aspx";
        }
    }
    
    static var AgreementUrl : String {
        get {
            return "http://\(host):\(port)/agreement.html"
        }
    }
    
}