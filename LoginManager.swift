//
//  LoginManager.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2019/1/23.
//  Copyright © 2019 tbaranes. All rights reserved.
//

import Foundation


class LoginManager {
    
    static var Refresh_Qiandao_After_Login : Bool = false
    static var Refresh_Yigou_After_Login : Bool = false
    
    let forkUserId = "11111111111"
    
    func makeNoLoginUser() -> LoginUser {
        let loginUser = LoginUser()
        loginUser.userName = forkUserId
        loginUser.password = forkUserId
        loginUser.name = "游客"
        loginUser.sex = "男"
        loginUser.codeImageUrl = ""
        loginUser.token = forkUserId
        loginUser.nickName = "游客"
        loginUser.level = ""
        loginUser.boss = ""
        
        return loginUser
    }
    
    func isUnlogin() -> Bool {
        return isAnymousUser(LoginUserStore().getLoginUser()!)
    }
    
    func isAnymousUser(_ user : LoginUserEntity) -> Bool {
        return user.userName == forkUserId
    }
    
    func goToLoginPage(_ controller : UIViewController) {
        //Storyboard
        let viewControllerStoryboardId = "LoginViewController"
        let storyboardName = "Main"
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: viewControllerStoryboardId) as! LoginViewController

        
        DispatchQueue.main.async { () -> Void in
            //controller.hidesBottomBarWhenPushed = true
            controller.navigationController?.pushViewController(vc, animated: true)
            //controller.hidesBottomBarWhenPushed = false
        }
    }
    
    func checkLogin(_ controller : UIViewController) {
        let loginUser = LoginUserStore().getLoginUser()
        if loginUser != nil {
            if isAnymousUser(loginUser!) {
                goToLoginPage(controller)
            }
        }
    }
    
    func handleAfterLogin(_ controller: UIViewController) {
        LoginManager.Refresh_Yigou_After_Login = true
        LoginManager.Refresh_Qiandao_After_Login = true
        if controller.navigationController != nil {
        
            let controllers = (controller.navigationController?.viewControllers)!
            
            var lastControlelr = controller
            var i = controllers.count - 1
            while i >= 0 {
                lastControlelr = controllers[i]
                if lastControlelr is LoginViewController {
                    if i - 1 >= 0 {
                        controller.navigationController?.popToViewController(controllers[i - 1], animated: true)
                        break
                    }
                }
                i = i - 1
            }
        }
    }
    
    func handleAfterLogout(_ controller: UIViewController) {
        
        let anymousUser = makeNoLoginUser()
        if LoginUserStore().saveLoginUser(loginUser: anymousUser) {
            
            //controller.navigationController?.popViewController(animated: true)
            let viewControllerStoryboardId = "tabBarController"
            let storyboardName = "Main"
            let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: viewControllerStoryboardId)
            
            
            DispatchQueue.main.async { () -> Void in
                //controller.hidesBottomBarWhenPushed = true
                //controller.navigationController?.pushViewController(vc, animated: true)
                //controller.hidesBottomBarWhenPushed = false
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window!.rootViewController = vc
            }
        }
        
    }
    
}
