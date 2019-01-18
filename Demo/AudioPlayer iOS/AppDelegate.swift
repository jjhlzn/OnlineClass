
//
//  AppDelegate.swift
//  AudioPlayer Sample
//
//  Created by Tom Baranes on 15/01/16.
//  Copyright © 2016 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer
import QorumLogs
import SwiftyBeaver


@UIApplicationMain
class AppDelegate : XinGeAppDelegate {

    var window: UIWindow?
    var loginUserStore = LoginUserStore()
    var audioPlayer = AudioPlayer()
    var liveProgressTimer : Timer?
var wxApiManager = WXApiManager()
    
    static let wbAppKey = "901768017"
    static let qqAppId = "1105796307"

    override func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        _ = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        QL1("didFinishLaunchingWithOptions")
        QorumLogs.enabled = true


        // Override point for customization after application launch.
        application.beginReceivingRemoteControlEvents()
        
        let serviceLocatorStore = ServiceLocatorStore()
        if serviceLocatorStore.GetServiceLocator() == nil {
            let serviceLocator = ServiceLocator()
            serviceLocator.http = "http"
            serviceLocator.serverName = "jf.yhkamani.com"
            serviceLocator.port = 80
            serviceLocator.isUseServiceLocator = "1"
            _ = serviceLocatorStore.saveServiceLocator(serviceLocator: serviceLocator)
        }

        
        registerForPushNotifications(application: application)
        NBSAppAgent.start(withAppID: "a200c16a118f4f99891ab5645fa2a13d")
        WXApi.registerApp("wx73653b5260b24787", withDescription: "AudioPlayer iOS")
        
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(AppDelegate.wbAppKey)
        
        setLogger()
       // [NBSAppAgent startWithAppID:@"a200c16a118f4f99891ab5645fa2a13d"];

        return true
    }

    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    override func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        super.application( application, didRegister: notificationSettings)
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    var deviceTokenString = ""
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        super.application( application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
     
        QL1("devicetoken: \(tokenString)")
        
        deviceTokenString = tokenString
        
        registerDeviceTokenToServer(completionHandler: nil)
    }
    
    
    func registerDeviceTokenToServer(completionHandler: ((_ response: RegisterDeviceResponse) -> Void)?) {
        let loginUser = loginUserStore.getLoginUser()
        if loginUser != nil {
            let request = RegisterDeviceRequest()
            request.deviceToken = deviceTokenString
            BasicService().sendRequest(url: ServiceConfiguration.REGISTER_DEVICE, request: request) {
                (resp: RegisterDeviceResponse) -> Void in
                print("register \(self.deviceTokenString) to \((loginUser?.userName)!)")
                if completionHandler  != nil {
                    completionHandler!(resp)
                }
            }
            
        }
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)  {
        print("Failed to register:", error)
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if let event = event {
            //TODO:
            //audioPlayer.remoteControlReceivedWithEvent(event)
            audioPlayer.remoteControlReceived(with: event)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        let currentViewController = getVisibleViewController(rootViewController: nil)
        
        if currentViewController != nil {
            if let navController = currentViewController as? UINavigationController {
                if let topController = navController.topViewController as? SongViewController {
                    topController.playerPageViewController.enterForhand()
                }
            }
        }
    }
   
    func applicationDidEnterBackground(_ application: UIApplication) {
        let currentViewController = getVisibleViewController(rootViewController: nil)
        
        if currentViewController != nil {
            if let navController = currentViewController as? UINavigationController {
                if let topController = navController.topViewController as? SongViewController {
                    topController.playerPageViewController.enterBackgound()
                }
            }
        }

    }
    
    /*
    func application(_ application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        QL1("application(UIApplication, url): ", url.absoluteString!)
        
        return WXApi.handleOpen(url as URL, delegate: wxApiManager)
    }
    
    
    func application(_ application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        QL1("application(UIApplication, url): \(url.absoluteString)")
        QL1("sourceApplication: \(sourceApplication == nil ? "nil" : sourceApplication!)")
        //tencent1105796307://response_from_qq
        
        //WeiboSDK.handleOpenURL(url, delegate: nil)
        return WXApi.handleOpen(url as URL, delegate: wxApiManager)
        
        
    } */
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        QL1("application(UIApplication, url): ", url.absoluteString)
        QL1("scheme: \(url.scheme)")
        if url.scheme == "wx73653b5260b24787" {
            return WXApi.handleOpen(url as URL, delegate: wxApiManager)
        }
        return true
    }
    
    
    
    private func getVisibleViewController( rootViewController: UIViewController?) -> UIViewController? {
        
        var rootViewController = rootViewController
        if rootViewController == nil {
            rootViewController = UIApplication.shared.keyWindow?.rootViewController
        }
        
        if rootViewController?.presentedViewController == nil {
            return rootViewController
        }
        
        if let presented = rootViewController?.presentedViewController {
            if presented is UINavigationController {
                let navigationController = presented as! UINavigationController
                print(navigationController.viewControllers.last!)
                return navigationController.viewControllers.last!
            }
            
            if presented is UITabBarController {
                let tabBarController = presented as! UITabBarController
                print(tabBarController.selectedViewController!)
                return tabBarController.selectedViewController!
            }
            
            return getVisibleViewController(rootViewController: presented)
        }
        return nil
    }


}

