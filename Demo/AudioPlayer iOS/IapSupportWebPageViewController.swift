//
//  WebPageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import WebKit
import StoreKit
import QorumLogs
import SwiftyJSON

class IapSupportWebPageViewController: BaseUIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver,
    WKScriptMessageHandler {
    var webView: WKWebView?
    
     var productIDs : NSSet = NSSet(objects: "com.jufang.onlineclass.oneyearvipclass2")
    
    var loadingOverlay = LoadingOverlayWithMessage()
    var buyAfterRequest = false
    var buyProductId = ""
    var theProduct = SKProduct()
    
    func initIAP() {
        if(SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
        } else {
            print("please enable IAPS")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SKPaymentQueue.default().add(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SKPaymentQueue.default().remove(self)
    }
    
    let contentController = WKUserContentController()
    func initWebView() {
        
        contentController.add(
            self,
            name: "payCallbackHandler"
        )
        contentController.add(
            self,
            name: "openApp"
        )
        contentController.add(
            self,
            name: "wechatPay"
        )
        
    }

    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        QL1("message.name = \(message.name)")
        if(message.name == "payCallbackHandler") {
            QL1("JavaScript is sending a message \(message.body)")
            
            let requestId = message.body
            buyProductId = requestId as! String
            
            if (!productIDs.contains(requestId) || theProduct.productIdentifier != buyProductId ){
                productIDs = NSSet(objects: requestId)
                QL1(productIDs)
                self.buyAfterRequest = true
                loadingOverlay.showOverlayWithMessage(msg:  "支付加载中", view: self.view)
                let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDs as! Set<String>)
                request.delegate = self
                request.start()
                return;
            }
            
            buyProduct(product: theProduct)
            
        } else if message.name == "wechatPay" {
            QL1("JavaScript is sending a message \(message.body)")
            //let json = JSON.parse(message.body as! String)
            wechatPay(json: message.body as! NSDictionary)
        }
        
        else if message.name == "openApp" {
            if UIApplication.shared.canOpenURL(NSURL(string: message.body as! String)! as URL)
            {
                UIApplication.shared.openURL(NSURL(string: message.body as! String)! as URL)
            }
        }
    }


    /***********   IAP相关的函数  *****************/

    
    func buyProduct(product: SKProduct) {
        QL4("buy " + product.productIdentifier)
        if product.productIdentifier != buyProductId {
            return
        }
        
        let pay = SKPayment(product: product)
        SKPaymentQueue.default().add(pay as SKPayment);
        loadingOverlay.showOverlayWithMessage(msg: "支付中", view: self.view)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            theProduct = product
        }
        
        if buyAfterRequest {
            loadingOverlay.hideOverlayView()
            buyProduct(product: theProduct)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("transactions restored")
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        QL1("paymentQueue(updatedTransactions)")
        loadingOverlay.hideOverlayView()
        for transaction:AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            QL1("error = \(trans.error)")
            QL1("state = \(trans.transactionState.rawValue)")
            switch trans.transactionState {
                
            case .purchased:
                QL1("Purchased")
                QL1(trans.payment.productIdentifier)
                let prodID = trans.payment.productIdentifier as String
                QL1("prodid = \(prodID)")
                
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                //将购买记录保存到本地数据库中
                let loginUserStore = LoginUserStore()
                let purchaseRecordStore = PurchaseRecordStore()
                let purchaseRecord = PurchaseRecord()
                purchaseRecord.isNotify = false
                purchaseRecord.payTime = dateFormat.string(from: NSDate() as Date)
                purchaseRecord.productId = prodID
                purchaseRecord.userid = loginUserStore.getLoginUser()?.userName!
                
                let purchaseRecordEntity = purchaseRecordStore.save(record: purchaseRecord)
                if purchaseRecordEntity == nil {
                    QL4("save purchase record entity error")
                } else {
                    QL1("save purchase record success")
                }
                //purchaseRecordStore.getAllNotifyRecord(purchaseRecord.userid)
                
                //将购买记录推送到巨方的服务器
                let request = NotifyIAPSuccessRequest()
                request.productId = prodID
                request.payTime = purchaseRecord.payTime
                
                //sign必须最后一个进行赋值
                request.sign = Utils.createIPANotifySign(request: request)
                
                BasicService().sendRequest(url: ServiceConfiguration.NOTIFY_IAP_SUCCESS, request: request) {
                    (resp : NotifyIAPSuccessResponse) -> Void in
                    if resp.status != ServerResponseStatus.Success.rawValue {
                        QL4("resp.status = \(resp.status), message = \(resp.errorMessage)")
                        return;
                    }
                    if purchaseRecordEntity != nil {
                        purchaseRecordEntity!.isnotify = true
                        purchaseRecordStore.update()
                    }
                }
                
                
                notifyBrowserPayResult(result: true)
                queue.finishTransaction(trans)
                break;
            case .failed:
                notifyBrowserPayResult(result: false)
                QL1("buy failed")
                queue.finishTransaction(trans)
                break;
            case .purchasing:
                QL1("purchasing")
                break
            case .deferred:
                QL1("defered")
                break
            default:
                //TODO: 通知浏览器支付失败
                //notifyBrowserPayResult(false)
                QL1("default")
                break;
                
            }
        }
    }
    
    private func notifyBrowserPayResult(result: Bool) {
        if result {
            webView?.evaluateJavaScript("notifyPayResult(true)", completionHandler: nil)
        } else {
            webView?.evaluateJavaScript("notifyPayResult(false)", completionHandler: nil)
        }
    }
    
    func finishTransaction(trans:SKPaymentTransaction)
    {
        print("finish trans")
        SKPaymentQueue.default().finishTransaction(trans)
    }

    
    /*********** 微信支付 ****************/
    func wechatPay(json: NSDictionary) {
        
        let request = PayReq()
        request.partnerId = json["partnerid"] as! String
        request.package = json["package"] as! String
        
        request.nonceStr = json["noncestr"] as! String
        request.prepayId = json["prepayid"] as! String
        request.timeStamp = UInt32(json["timestamp"] as! String)!
        request.sign = json["sign"] as! String
        WXApi.send(request)
    }
    
        
}
