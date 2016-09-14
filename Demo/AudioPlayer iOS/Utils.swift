//
//  Utils.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit
import KDEAudioPlayer

import QorumLogs

extension String {
    var length: Int {
        return characters.count
    }
}

extension String {
    public func indexOfCharacter(char: Character) -> Int? {
        if let idx = self.characters.indexOf(char) {
            return self.startIndex.distanceTo(idx)
        }
        return nil
    }
}

class Utils {
    static let Model_Name = "jufangzhushou"
    
    static func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    static func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
    }
    
    static func getAudioPlayer() -> AudioPlayer {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.audioPlayer
    }
    
    static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    static func getCurrentTime() -> String {
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.stringFromDate(currentDateTime)
    }
    
    
    
    static func addUserParams(url : String) -> String {
        let loginUserStore = LoginUserStore()
        let loginUser = loginUserStore.getLoginUser()
        if loginUser != nil {
            if url.indexOfCharacter("?") != nil {
                return url + "&userid=\(loginUser!.userName!)&token=\(loginUser!.token!)"
            } else {
                return url + "?userid=\(loginUser!.userName!)&token=\(loginUser!.token!)"
            }
        }
        return url
    }
    
    static func addDevcieParam(url : String) -> String {
        let model = UIDevice.currentDevice().model
        let osversion = UIDevice.currentDevice().systemVersion
        
        let screensize = UIScreen.mainScreen().bounds
        let screenInfo = "\(screensize.width)*\(screensize.height)"
        
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let appBundle = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        let appversion = "\(version).\(appBundle)"

        
        
        var newurl = url
        
        if url.indexOfCharacter("?") != nil {
            newurl = url + "&"
        } else {
            newurl = url + "?"
        }
        
        
        var deviceParamsString  = "platform=iphone&model=\(model)&osversion=\(osversion)&screensize=\(screenInfo)&appversion=\(appversion)"
        
        deviceParamsString = deviceParamsString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        newurl = newurl + deviceParamsString
        
        return newurl
    }
    
    static func md5(string string: String) -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    static let secretkey = "jufangjituan987768898affbfsdfdfdfdf&^%fdfdf#@fdfdf1111"
    static func createIPANotifySign(request: NotifyIAPSuccessRequest) -> String {
        let loginUserStore = LoginUserStore()
        let loginUser = loginUserStore.getLoginUser()
        var string = request.productId  + request.payTime
        string = string + loginUser!.userName! + secretkey
        QL1("string = \(string)")
        let sign = md5(string: string)
        QL1("sign = \(sign)")
        return sign
    }


}



extension UIImageView {
    func becomeCircle() {
        self.layer.borderWidth = 0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true

    }
}

extension UIImage{
    func scaledToSize(size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

import UIKit

enum viewBorder: String {
    case Left = "borderLeft"
    case Right = "borderRight"
    case Top = "borderTop"
    case Bottom = "borderBottom"
}

extension UIView {
    
    func addBorder(vBorder: viewBorder, color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.name = vBorder.rawValue
        switch vBorder {
        case .Left:
            border.frame = CGRectMake(0, 0, width, self.frame.size.height)
        case .Right:
            border.frame = CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height)
        case .Top:
            border.frame = CGRectMake(0, 0, self.frame.size.width, width)
        case .Bottom:
            border.frame = CGRectMake(0, self.frame.size.height - width, self.frame.size.width, width)
        }
        self.layer.addSublayer(border)
    }
    
    func removeBorder(border: viewBorder) {
        var layerForRemove: CALayer?
        for layer in self.layer.sublayers! {
            if layer.name == border.rawValue {
                layerForRemove = layer
            }
        }
        if let layer = layerForRemove {
            layer.removeFromSuperlayer()
        }
    }
    
}