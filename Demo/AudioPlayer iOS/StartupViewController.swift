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
    
    var loginUserStore = LoginUserStore()
    var serviceLocatorStore = ServiceLocatorStore()
    var isForceUpgrade = false
    var isSkipUpgradeCheck = false
    var upgradeUrl : String!
    
    var optionalUpgradeAlertViewDelegate : OptionalUpgradeAlertViewDelegate!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        optionalUpgradeAlertViewDelegate = OptionalUpgradeAlertViewDelegate(controller: self)

        let serviceLocator = serviceLocatorStore.GetServiceLocator()
        
        //serviceLocator不应该为null，因为在AppDelegate会有一个初始化值
        if (serviceLocator?.needServieLocator)! {
            
            BasicService().sendRequest(ServiceConfiguration.GET_SERVICE_LOACTOR_URL, request: GetServiceLocatorRequest()) {
                (resp : GetServiceLocatorResponse) -> Void in
                
                if resp.status == ServerResponseStatus.Success.rawValue {
                    serviceLocator?.http = resp.http
                    serviceLocator?.port = resp.port
                    serviceLocator?.serverName = resp.serverName
                    
                    self.serviceLocatorStore.UpdateServiceLocator()
                }
                
                self.checkUpgrade()
                
            }
        } else {
            checkUpgrade()
        }
        
    }
    
    private func checkLoginUser() {
        
        //检查一下是否已经登录，如果登录，则直接进入后面的页面
        let loginUser = loginUserStore.getLoginUser()
        if  loginUser != nil {
            QL1("found login user")
            QL1("userid = \(loginUser?.userName), password = \(loginUser?.password), token = \(loginUser?.token)")
            self.performSegueWithIdentifier("hasLoginSegue", sender: self)
        } else {
            QL1("no login user")
            self.performSegueWithIdentifier("notLoginSegue", sender: self)
        }

    }
    

    
    func displayOptionUpgradeConfirmMessage(message : String, delegate: UIAlertViewDelegate) {
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButtonWithTitle("去升级")
        alertView.addButtonWithTitle("取消")
        alertView.delegate=delegate
        alertView.show()
    }
    
    
    func displayForceUpgradeConfirmMessage(message : String, delegate: UIAlertViewDelegate) {
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButtonWithTitle("去升级")
        alertView.delegate=delegate
        alertView.show()
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "upgradeSegue" {
            let dest = segue.destinationViewController as! UpgradeViewController
            dest.isForceUpgrade = isForceUpgrade
            //TODO 链接要换成真是的升级链接
            dest.url = NSURL(string: upgradeUrl )
        }
    }
    
    func checkUpgrade() {
        if isSkipUpgradeCheck {
            checkLoginUser()
        } else {
            BasicService().sendRequest(ServiceConfiguration.CHECK_UPGRADE, request: CheckUpgradeRequest()) {
                (resp : CheckUpgradeResponse) -> Void in
                if resp.status != 0 {
                    self.displayMessage(resp.errorMessage!)
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

    }
    
    
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
    }
    

}
