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

class WebPageViewController: BaseUIViewController, WKScriptMessageHandler, SKProductsRequestDelegate, SKPaymentTransactionObserver, WKNavigationDelegate {
    
    var url : NSURL!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    //var backButton: UIBarButtonItem!
    
    var leftBarButtonItems: [UIBarButtonItem]?
    var webView: WKWebView?

    @IBOutlet weak var webContainer: UIView!
    var loading = LoadingCircle()
    var loadingOverlay = LoadingOverlayWithMessage()
    
    var productIDs : NSSet = NSSet(objects: "com.jufang.onlineclass.oneyearvipclass")
    var buyAfterRequest = false
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initIAP()
        initWebView()
        
        closeButton.target = self
        closeButton.action = #selector(returnLastController)
        
        backButton.target = self
        backButton.action = #selector(webViewBack)
        leftBarButtonItems = navigationItem.leftBarButtonItems

  
        navigationItem.leftBarButtonItems = [backButton]
        addLineBorder(cancelButton)
        shareView.hidden = true
        if title == "提额秘诀" {
            
        } else {
            navigationItem.rightBarButtonItems = []
        }
        
    }
    
    private func initIAP() {
        if(SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            //let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDs as! Set<String>)
            //request.delegate = self
            //request.start()
        } else {
            print("please enable IAPS")
        }

    }
    
    
    let contentController = WKUserContentController()
    private func initWebView() {
        var url1 = url.absoluteString
        url1 = Utils.addUserParams(url1)
        url1 = Utils.addDevcieParam(url1)
        print(url1)
        
        contentController.addScriptMessageHandler(
            self,
            name: "payCallbackHandler"
        )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        
        self.webContainer.addSubview(self.webView!)
        self.webView?.navigationDelegate = self
        
        let nsurl = NSURL(string: url1)
        QL1("NSUrl = \(nsurl)")
        let myRequest = NSURLRequest(URL: nsurl!);
        //webView.delegate = self
        webView!.loadRequest(myRequest);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    

    /****  webView相关的函数  ***/
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        loading.show(view)
        QL1("webView.canGoBack = \(webView.canGoBack)")
        if webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton, closeButton]
            backButton.action = #selector(webViewBack)
        }
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        loading.hide()
        QL1("webView.canGoBack = \(webView.canGoBack)")
        if !webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton]
            backButton.action = #selector(returnLastController)
        }
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        loading.hide()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        loading.hide()
    }

    
    func webViewBack() {
        if webView!.canGoBack {
            
            webView!.goBack()
            
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func returnLastController() {
        var controllers = navigationController?.viewControllers
        if controllers?.count >= 2 {
            let top = controllers![1] as? AlbumListController
            if top != nil {
                controllers?.removeLast(2)
                navigationController?.setViewControllers(controllers!, animated: true)
                return
            }
        }
        navigationController?.popViewControllerAnimated(true)
        
    }
    

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "payCallbackHandler") {
            QL1("JavaScript is sending a message \(message.body)")
            let requestId = message.body
            buyProductId = requestId as! String
            
            if (!productIDs.containsObject(requestId) || theProduct.productIdentifier != buyProductId ){
                productIDs = NSSet(objects: requestId)
                QL1(productIDs)
                self.buyAfterRequest = true
                loadingOverlay.showOverlayWithMessage("支付加载中", view: self.view)
                let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDs as! Set<String>)
                request.delegate = self
                request.start()
                return;
            }
            
            buyProduct(theProduct)
            
        }
    }
    
    /***********   IAP相关的函数  *****************/
    var buyProductId = ""
    var theProduct = SKProduct()
    
    private func buyProduct(product: SKProduct) {
         QL4("buy " + product.productIdentifier)
        if product.productIdentifier != buyProductId {
            return
        }
       
        let pay = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment);
        loadingOverlay.showOverlayWithMessage("支付中", view: self.view)
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
            theProduct = product
        }
        
        if buyAfterRequest {
            loadingOverlay.hideOverlayView()
            buyProduct(theProduct)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("transactions restored")
    }
    
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        QL1("add paymnet")
        loadingOverlay.hideOverlayView()
        for transaction:AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            QL1("error = \(trans.error)")
            QL1("state = \(trans.transactionState.rawValue)")
            switch trans.transactionState {
            
            case .Purchased:
                QL1("buy, ok unlock iap here")
                QL1(trans.payment.productIdentifier)
                let prodID = trans.payment.productIdentifier as String
                QL1("prodid = \(prodID)")
                
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                //将购买记录保存到本地数据库中
                let loginUserStore = LoginUserStore()
                let purchaseRecordStore = PurchaseRecordStore()
                let purchaseRecord = PurchaseRecord()
                purchaseRecord.isNotify = false
                purchaseRecord.payTime = dateFormat.stringFromDate(NSDate())
                purchaseRecord.productId = prodID
                purchaseRecord.userid = loginUserStore.getLoginUser()?.userName!
                
                let purchaseRecordEntity = purchaseRecordStore.save(purchaseRecord)
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
                request.sign = Utils.createIPANotifySign(request)
                
                BasicService().sendRequest(ServiceConfiguration.NOTIFY_IAP_SUCCESS, request: request) {
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
                

                notifyBrowserPayResult(true)
                queue.finishTransaction(trans)
                break;
            case .Failed:
                notifyBrowserPayResult(false)
                QL1("buy error")
                queue.finishTransaction(trans)
                break;
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
        SKPaymentQueue.defaultQueue().finishTransaction(trans)
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction])
    {
        print("remove trans");
    }
    
    
    /******************* 分享 *************************************************/
    var shareViewOverlay : UIView!
    @IBAction func shareButtonPressed(sender: AnyObject) {
        QL1("Share Button Pressed")
        if !shareView.hidden {
            return
        }
        print("showShareView")
        shareViewOverlay = UIView(frame: UIScreen.mainScreen().bounds)
        shareViewOverlay.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
        shareView.removeFromSuperview()
        shareViewOverlay.addSubview(shareView)
        
        view.addSubview(shareViewOverlay)
        
        shareView.hidden = false
        
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            print("winxin share is OK")
        } else {
            print("winxin share is  NOT OK")
        }
    }
    
    @IBAction func shareFriendsPressed(sender: AnyObject) {
        print("share to friends")
        share(false)
    }
    
    @IBAction func sharePengyouquanPressed(sender: AnyObject) {
        print("share to pengyouquan")
        share(true)
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        shareView.hidden = true
        shareView.removeFromSuperview()
        view.addSubview(shareView)
        shareViewOverlay.removeFromSuperview()
    }
    
    func addLineBorder(field: UIButton) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, 0, field.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        field.layer.addSublayer(bottomBorder)
    }
    
    
    
    private func share(isPengyouquan: Bool) {
        let message = WXMediaMessage()
        message.title = "扫一扫下载安装【巨方助手】，即可免费在线学习、提额、办卡、贷款！"
        message.description = "扫一扫下载安装【巨方助手】"
        message.setThumbImage(UIImage(named: "me_qrcode"))
        
        let webPageObject = WXWebpageObject()
        let loginUser = LoginUserStore().getLoginUser()!
        webPageObject.webpageUrl = ServiceLinkManager.ShareTiEMijueUrl + "?userid=\(loginUser.userName!)"
        message.mediaObject = webPageObject
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = (isPengyouquan ? 1 : 0)
        
        WXApi.sendReq(req)
        
        
    }



}
