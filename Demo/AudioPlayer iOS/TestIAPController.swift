//
//  TestIAPController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/9/7.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import StoreKit

class TestIAPController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var list = [SKProduct]()
    var p = SKProduct()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set IAPS
        if(SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            let productID:NSSet = NSSet(objects: "com.jufang.onlineclass.oneyearvipcourse1")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            print("please enable IAPS")
        }
    }
    
    @IBAction func buyPressed(sender: UIButton) {
        if list.count > 0 {
            p = list[0]
            buyProduct(p)
        }
    }
    
    @IBAction func webPagePressed(sender: UIButton) {
        performSegueWithIdentifier("buyVipSegue", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! WebPageViewController
        if segue.identifier == "bugVipSegue" {
            dest.title = "购买VIP"
            dest.url = NSURL(string: "http://192.168.1.68:3000/app/buyvip.html")
            //dest.url = NSURL(string: "http://www.baidu.com")

        }
    }
    
    private func buyProduct(product: SKProduct) {
        let p = product
        print("buy " + p.productIdentifier)
        let pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment);
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            list.append(product )
        }
        

    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("transactions restored")
        
    }
    
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add paymnet")
    }
    
    func finishTransaction(trans:SKPaymentTransaction)
    {
        print("finish trans")
        SKPaymentQueue.defaultQueue().finishTransaction(trans)
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction])
    {
        print("remove trans");
    }
    

}
