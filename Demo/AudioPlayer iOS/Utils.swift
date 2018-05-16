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
        return count
    }
}

extension String {
    public func indexOfCharacter(char: Character) -> Int? {
        if let idx = index(of: char) {
            return distance(from: startIndex, to: idx)
        }
        return nil
    }
}

class Utils {
    static let Model_Name = "jufangzhushou"
    
    static func getDataFromUrl(url:NSURL, completion: @escaping ((_ data: NSData?, _ response: URLResponse?, _ error: NSError? ) -> Void)) {
        URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
            completion(data as! NSData, response, error as! NSError)
            }.resume()
    }
    
    static func stringFromTimeInterval(interval: TimeInterval) -> String {
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.audioPlayer
    }
    
    static func delay(delay:Double, closure:()->()) {
        
        //TODO: 临时去掉
        /*
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure) */
    }
    
    static func getCurrentTime() -> String {
        let currentDateTime = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: currentDateTime as Date)
    }
    
    
    
    static func addUserParams(url : String) -> String {
        let loginUserStore = LoginUserStore()
        let loginUser = loginUserStore.getLoginUser()
        if loginUser != nil {
            if url.indexOfCharacter(char: "?") != nil {
                return url + "&userid=\(loginUser!.userName!)&token=\(loginUser!.token!)"
            } else {
                return url + "?userid=\(loginUser!.userName!)&token=\(loginUser!.token!)"
            }
        }
        return url
    }
    
    static func addDevcieParam(url : String) -> String {
        let model = UIDevice.current.model
        let osversion = UIDevice.current.systemVersion
        
        let screensize = UIScreen.main.bounds
        let screenInfo = "\(screensize.width)*\(screensize.height)"
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let appBundle = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        let appversion = "\(version).\(appBundle)"

        
        
        var newurl = url
        
        if url.indexOfCharacter(char: "?") != nil {
            newurl = url + "&"
        } else {
            newurl = url + "?"
        }
        
        
        var deviceParamsString  = "platform=iphone&model=\(model)&osversion=\(osversion)&screensize=\(screenInfo)&appversion=\(appversion)"
        
        //TODO:
        //deviceParamsString = deviceParamsString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        deviceParamsString = deviceParamsString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        newurl = newurl + deviceParamsString
        
        return newurl
    }
    
    static func md5(_ string: String) -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
    static let secretkey = "jufangjituan987768898affbfsdfdfdfdf&^%fdfdf#@fdfdf1111"
    static func createIPANotifySign(request: NotifyIAPSuccessRequest) -> String {
        let loginUserStore = LoginUserStore()
        let loginUser = loginUserStore.getLoginUser()
        var string = request.productId  + request.payTime
        string = string + loginUser!.userName! + secretkey
        QL1("string = \(string)")
        let sign = md5(string)
        QL1("sign = \(sign)")
        return sign
    }
    
    static func getWebpageObject()-> WBMessageObject
    {
        let message = WBMessageObject()
        
        let webpage = WBWebpageObject()
        webpage.objectID = "\(NSDate().timeIntervalSince1970 * 1000)"
        webpage.title = "扫一扫下载安装【巨方助手】，即可免费在线学习、提额、办卡、贷款！"
        webpage.description =  "扫一扫下载安装【巨方助手】"
        
        //webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
        webpage.thumbnailData = UIImagePNGRepresentation(UIImage(named: "me_qrcode")!)
        
        let loginUser = LoginUserStore().getLoginUser()!
        
        webpage.webpageUrl = ServiceLinkManager.ShareTiEMijueUrl + "?userid=\(loginUser.userName!)"
        message.mediaObject = webpage;
        
        
        return message
    }
    
    static func hasInstalledWeixin() -> Bool {
        return hasInstalledApp(scheme: "weixin")    }

    static func hasInstalledQQ() -> Bool {
        return hasInstalledApp(scheme: "mqq")
    }

    static func hasInstalledApp(scheme: String) -> Bool {
        let url = "\(scheme)://"
        if UIApplication.shared.canOpenURL(NSURL(string: url)! as URL) {
            return true
        }
        return false
    }



}

extension UISearchBar {
    func changeSearchBarColor(color: UIColor) {
        UIGraphicsBeginImageContext(self.frame.size)
        color.setFill()
        UIBezierPath(rect: self.frame).fill()
        let bgImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.setSearchFieldBackgroundImage(bgImage, for: .normal)
    }
}

extension UIImageView {
    func becomeCircle() {
        self.layer.borderWidth = 0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true

    }
}

extension UIImage{
    func scaledToSize(size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        self.draw(in: CGRect(x:0, y:0, width: size.width, height: size.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
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
        border.backgroundColor = color.cgColor
        border.name = vBorder.rawValue
        switch vBorder {
        case .Left:
            border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        case .Right:
            border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        case .Top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        case .Bottom:
            border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
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
