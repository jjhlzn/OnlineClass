//
//  StartupViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/6.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs

class StartupViewController: BaseUIViewController {
    
    @IBOutlet weak var advImageView: UIImageView!
    @IBOutlet weak var skipAdvButton: UILabel!
    @IBOutlet weak var advTip: UILabel!
    
    
    var loginUserStore = LoginUserStore()
    var serviceLocatorStore = ServiceLocatorStore()
    var isForceUpgrade = false
    var isSkipUpgradeCheck = false
    var upgradeUrl : String!
    
    //var optionalUpgradeAlertViewDelegate : OptionalUpgradeAlertViewDelegate!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        advImageView.isHidden = true
        skipAdvButton.isHidden = true
        advTip.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // optionalUpgradeAlertViewDelegate = OptionalUpgradeAlertViewDelegate(controller: self)
        
        //let serviceLocator = serviceLocatorStore.GetServiceLocator()
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        
        //serviceLocator不应该为null，因为在AppDelegate会有一个初始化值
         //self.checkLaunchAdv()
        
        //goToNextControllerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.skipAdvWhenTimeOut), userInfo: nil, repeats: true)
        
    }
    
    var goToNextControllerTimer : Timer?
    var skipAdvTimeCount = 7
    @objc func skipAdvWhenTimeOut() {
        skipAdvTimeCount = skipAdvTimeCount - 1
        if skipAdvTimeCount <= 0 {
            goToNextControllerTimer?.invalidate()
            checkLoginUser()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func checkLoginUser() {
        
        //检查一下是否已经登录，如果登录，则直接进入后面的页面
        let loginUser = loginUserStore.getLoginUser()
        if  loginUser != nil {
            QL1("found login user")
            QL1("userid = \(loginUser?.userName), password = \(loginUser?.password), token = \(loginUser?.token)")
            self.performSegue(withIdentifier: "hasLoginSegue", sender: self)
        } else {
            QL1("no login user")
            self.performSegue(withIdentifier: "notLoginSegue", sender: self)
        }
        
    }
    
    @objc func skipAdv() {
        QL1("skip adv")
        goToNextControllerTimer?.invalidate()
        skipAdvTimer?.invalidate()
        checkLoginUser()
    }
    
    var advUrl = ""
    var advTitle = ""
    @objc func goToAdvPage() {
        QL1("go to adv page")
        if "" != advUrl {
            goToNextControllerTimer?.invalidate()
            skipAdvTimer?.invalidate()
            performSegue(withIdentifier: "webViewSegue", sender: ["url": advUrl, "title": advTitle])
        }
    }
    
    private func setAdvImage(imageUrl: String, advUrl: String, advTitle: String) {
        self.advUrl = advUrl
        self.advTitle = advTitle
        
        //let imageView = UIImageView()
        
        advImageView.kf.setImage(with: URL(string: imageUrl)!)
        advImageView.isHidden = false
        skipAdvButton.isHidden = false
        self.advTip.isHidden = false
        
        self.skipAdvButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.skipAdv)))
        self.skipAdvButton.isUserInteractionEnabled = true
        
        self.advImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.goToAdvPage)))
        self.advImageView.isUserInteractionEnabled = true
        
        //设置timer
        self.skipAdvTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateSkipAdvButtonText), userInfo: nil, repeats: true)
        
    }
    
    var timerCount = 3
    var skipAdvTimer: Timer?
    @objc func updateSkipAdvButtonText() {
        timerCount = timerCount - 1
        self.skipAdvButton.text = "跳过广告 \(timerCount)"
        
        if timerCount <= 0 {
            skipAdvTimer?.invalidate()
            timerCount = 4
            checkLoginUser()
        }
    }
    
    
    private func checkLaunchAdv() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_LAUNCH_ADV, request: GetLaunchAdvRequest(), timeout: 3) {
            (resp: GetLaunchAdvResponse) -> Void in
            
            if resp.status == ServerResponseStatus.Success.rawValue {
                if "" != resp.imageUrl {
                    self.setAdvImage(imageUrl: resp.imageUrl, advUrl: resp.advUrl, advTitle: resp.advTitle)
                } else {
                    self.checkLoginUser()
                }
            } else {
                self.checkLoginUser()
            }
        }
    }
    
    
    
    func displayOptionUpgradeConfirmMessage(message : String, delegate: UIAlertViewDelegate) {
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButton(withTitle: "去升级")
        alertView.addButton(withTitle: "取消")
        alertView.delegate=delegate
        alertView.show()
    }
    
    
    func displayForceUpgradeConfirmMessage(message : String, delegate: UIAlertViewDelegate) {
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButton(withTitle: "去升级")
        alertView.delegate=delegate
        alertView.show()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "upgradeSegue" {
            let dest = segue.destination as! UpgradeViewController
            dest.isForceUpgrade = isForceUpgrade
            //TODO 链接要换成真是的升级链接
            dest.url = NSURL(string: upgradeUrl )
        } else if segue.identifier == "webViewSegue" {
            let params = sender as! [String : String]
            let dest = segue.destination as! WebPageViewController
            dest.title =  params["title"]
            dest.url = NSURL(string: params["url"]!)
            dest.isBackToMainController = true
        }
    }
    
    /*
     func checkUpgrade() {
     if isSkipUpgradeCheck {
     checkLoginUser()
     } else {
     BasicService().sendRequest(ServiceConfiguration.CHECK_UPGRADE, request: CheckUpgradeRequest()) {
     (resp : CheckUpgradeResponse) -> Void in
     if resp.status != 0 {
     //self.displayMessage(resp.errorMessage!)
     self.checkLoginUser()
     return
     }
     
     if resp.isNeedUpgrade {
     self.isForceUpgrade = ("force" == resp.upgradeType)
     self.upgradeUrl = resp.upgradeUrl
     if self.isForceUpgrade {
     self.displayForceUpgradeConfirmMessage ("请升级新版本", delegate: self.optionalUpgradeAlertViewDelegate)
     } else {
     self.displayOptionUpgradeConfirmMessage("有新版本，去升级吗？", delegate: self.optionalUpgradeAlertViewDelegate)
     }
     } else {
     self.checkLoginUser()
     }
     }
     
     
     }
     
     }*/
    
    /*
     class OptionalUpgradeAlertViewDelegate : NSObject, UIAlertViewDelegate {
     
     var controller : StartupViewController
     
     init(controller: StartupViewController) {
     self.controller = controller
     }
     
     func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
     switch buttonIndex {
     case 0:
     
     controller.performSegueWithIdentifier("upgradeSegue", sender: nil)
     break;
     case 1:
     controller.checkLoginUser()
     break;
     default:
     break;
     }
     }
     }*/
    
    
}
