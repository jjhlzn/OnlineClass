//
//  XinGeAppDelegate.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/8/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//
import UIKit
import SwiftyBeaver

let IPHONE_8:Int32 = 80000


/// ACCESS ID
let kXinGeAppId: UInt32 = 2200199272

/// ACCESS KEY
let kXinGeAppKey:String! = "I5RT4RI429SR"

class XinGeAppDelegate: UIResponder, UIApplicationDelegate {
    
    func setLogger() {
        let log = SwiftyBeaver.self
        let console = ConsoleDestination()  // log to Xcode Console
        //let file = FileDestination()  // log to default swiftybeaver.log file
        //let cloud = SBPlatformDestination(appID: "foo", appSecret: "bar", encryptionKey: "123") // to cloud
        
        // use custom format and set console output to short time, log level & message
        console.format = "$DHH:mm:ss$d $L $M"
        // or use this for JSON output: console.format = "$J"
        
        // add the destinations to SwiftyBeaver
        log.addDestination(console)
        //log.addDestination(file)
        //log.addDestination(cloud)
        print("setLogger")
        
    }
    
    func registerPushForIOS8()
    {
        //Types
        //var types = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        
        //Actions
        let acceptAction = UIMutableUserNotificationAction()
        
        acceptAction.identifier = "ACCEPT_IDENTIFIER"
        acceptAction.title      = "Accept"
        
        acceptAction.activationMode = UIUserNotificationActivationMode.foreground
        
        acceptAction.isDestructive = false
        acceptAction.isAuthenticationRequired = false
        
        
        //Categories
        let inviteCategory = UIMutableUserNotificationCategory()
        inviteCategory.identifier = "INVITE_CATEGORY";
        
        inviteCategory.setActions([acceptAction], for: UIUserNotificationActionContext.default)
        inviteCategory.setActions([acceptAction], for: UIUserNotificationActionContext.minimal)
        
        //var categories = NSSet(objects: inviteCategory)
        
        //var mySettings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: categories as Set<NSObject>)
        let mySettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)

        
        UIApplication.shared.registerUserNotificationSettings(mySettings)
        
    }
    
    func registerPush()
    {
       
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        setLogger()
        // 注册
        XGPush.startApp(kXinGeAppId, appKey: kXinGeAppKey)
        
        XGPush.initForReregister { () -> Void in
            //如果变成需要注册状态
            if !XGPush.isUnRegisterStatus()
            {
                
                if __IPHONE_OS_VERSION_MAX_ALLOWED >= IPHONE_8
                {
                    self.registerPush()
                    /*
                    if (UIDevice.current.systemVersion.compare("8", options:.NumericSearch) != ComparisonResult.OrderedAscending)
                    {
                        self.registerPushForIOS8()
                    }
                    else
                    {
                        self.registerPush()
                    } */
                    
                }
                else
                {
                    //iOS8之前注册push方法
                    //注册Push服务，注册后才能收到推送
                    self.registerPush()
                }
                
                
            }
        }
        
        XGPush.handleLaunching(launchOptions, successCallback: { () -> Void in
            print("[XGPush]handleLaunching's successBlock\n\n")
        }) { () -> Void in
            print("[XGPush]handleLaunching's errorBlock\n\n")
        }
        
        return true
    }
    
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        XGPush.localNotification(atFrontEnd: notification, userInfoKey: "clockID", userInfoValue: "myid")
        
        XGPush.delLocalNotification(notification)
    }
    
    
 
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        if let ident = identifier
        {
            if ident == "ACCEPT_IDENTIFIER"
            {
                print("ACCEPT_IDENTIFIER is clicked\n\n")
            }
        }
        
        completionHandler()
    }
    
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        //注册设备
        //        XGSetting.getInstance().Channel = ""//= "appstore"
        //        XGSetting.getInstance().GameServer = "家万户"
        //XGPush.setAccount("13706794299")
        let deviceTokenStr = XGPush.registerDevice(deviceToken as Data!, successCallback: { () -> Void in
            print("[XGPush]register successBlock\n\n")
        }) { () -> Void in
            print("[XGPush]register errorBlock\n\n")
        }
        
        print("deviceTokenStr:\(deviceTokenStr)\n\n")
        
       
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotifications error:\(error.localizedDescription)\n\n")
    }
    
    // iOS 3 以上
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        //        UIAlertView(title: "3-", message: "didReceive", delegate: self, cancelButtonTitle: "OK").show()
        let info = userInfo as! [String : AnyObject]
        var apsDictionary = info["aps"] as? NSDictionary
       
        if let apsDict = apsDictionary
        {
            var alertView = UIAlertView(title: "您有新的消息", message: apsDict["alert"] as? String, delegate: self, cancelButtonTitle: "确定")
            alertView.show()
        }
        
        // 清空通知栏通知
        XGPush.clearLocalNotifications()
        UIApplication.shared.cancelAllLocalNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        XGPush.handleReceiveNotification(userInfo)
    }
    
    // iOS 7 以上
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)
    {
        //        UIAlertView(title: "7-", message: "didReceive", delegate: self, cancelButtonTitle: "OK").show()
        let info = userInfo as! [String : AnyObject]
        var apsDictionary = info["aps"] as? NSDictionary
        if let apsDict = apsDictionary
        {
            var alertView = UIAlertView(title: "您有新的消息", message: apsDict["alert"] as? String, delegate: self, cancelButtonTitle: "确定")
            alertView.show()
        }
        // 清空通知栏通知
        XGPush.clearLocalNotifications()
        UIApplication.shared.cancelAllLocalNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        XGPush.handleReceiveNotification(userInfo)
    }
    
    
    
}
