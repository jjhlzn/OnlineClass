//
//  TestIAPController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/9/7.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import StoreKit

class TestIAPController: UIViewController, SKProductsRequestDelegate {
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
            buyProduct(product: p)
        }
    }
    
    @IBAction func webPagePressed(sender: UIButton) {
        performSegue(withIdentifier: "buyVipSegue", sender: nil)
    }


    
    private func buyProduct(product: SKProduct) {
        let p = product
        print("buy " + p.productIdentifier)
        let pay = SKPayment(product: p)
        SKPaymentQueue.default().add(self as! SKPaymentTransactionObserver)
        SKPaymentQueue.default().add(pay as SKPayment);
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
        SKPaymentQueue.default().finishTransaction(trans)
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction])
    {
        print("remove trans");
    }
    

}
