//
//  ServiceLinkManager.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/28.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation


class ServiceLinkManager {

    
    static var MyTuiJianUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Center/MyTuiJian"
        }
    }
    
    static var MyOrderUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Center/MyOrder"
        }
    }
    
    static var MyAgentUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Center/MyAgent"
        }
    }
    
    static var MyExchangeUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Center/MyExchange"
        }
    }
    
    static var MyTeamUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Center/MyTeam"
        }
    }
    
    static var FunctionCardManagerUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Service/CardManage"
        }
    }
    
    static var FunctionCustomerServiceUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Service/Custom"
        }
    }

    
    static var FunctionUpUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Service/CreditLines"
        }
    }
    
    static var FunctionFastCardUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Service/FastCard"
        }
    }
    
    static var FunctionCreditSearchUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Service/Ipcrs"
        }
    }
    
    
    static var FunctionMccSearchUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Service/MccSearch"
        }
    }
    
    static var FunctionJiaoFeiUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Service/Fee"
        }
    }
    
    static var FunctionDaiKuangUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Service/Loan"
        }
    }
    
    static var FunctionCarLoanUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Service/CarLoan"
        }
    }
    
    static var FunctionShopUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/shop/shopindex"
        }
    }
    
    static var ShareQrImageUrl : String {
        get {
            return "http://jf.yhkamani.com/Center/MyLink.aspx"
        }
    }
    
    static var ShareTiEMijueUrl : String {
        get {
            return "http://jf.yhkamani.com/Center/MyLink.aspx"
        }
    }
    
    static var AgreementUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/agreement.html"
        }
    }
    
    static var MyJifenUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Center/MyPoint"

        }
    }
    
    static var MyChaifuUrl : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Center/MyMoney"
            
        }
    }
    
    static var MyTeamUrl2 : String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Center/MyTeam2"
            
        }
    }
    
    static var PersonalInfoUrl: String {
        get {
            return "http://\(ServiceConfiguration.serverName):\(ServiceConfiguration.port)/Center/PersonalInfo"
        }
    }
    
    static var ChatUrl : String {
        get {
            return "http://chat.yhkamani.com"
        }
    }
    
}