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
import Kingfisher
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

class ImageCacheKeys {
    static let User_Profile_Image = "key_User_Profile_Image"
}

class Utils {
    static let Model_Name = "jufangzhushou"
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func setUserHeadImageView(_ headImageView: UIImageView, userId: String) {
        headImageView.becomeCircle()
        //headImageView.layer.borderWidth = 0.3
        headImageView.layer.borderColor = UIColor.lightGray.cgColor
        let url =  ServiceConfiguration.GET_PROFILE_IMAGE + "?userid=" + userId
        QL1(url)
        if let downloadURL = URL(string: url) {
            let resource = ImageResource(downloadURL: downloadURL, cacheKey: "headimage_"+userId)
            headImageView.kf.setImage(with: resource, placeholder: UIImage(named: "func_placeholder"))
        }
    }
    
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
    
    static func delay(delay:Double, closure:@escaping ()->()) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { // change 2 to desired number of seconds
            // Your code with delay
            closure()
        }
        
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
    

    static func getCurrentSong() -> LiveSong {
        let audioPlayer = getAudioPlayer()
        let song = (audioPlayer.currentItem as! MyAudioItem).song as! LiveSong
        return song
    }

    static func setNavigationBarAndTableView(_ controller: UIViewController,  tableView: UITableView?) {
        if #available(iOS 11.0, *) {
            tableView?.contentInsetAdjustmentBehavior = .never
            if UIDevice().isX() {
                tableView?.contentInset = UIEdgeInsetsMake(24, 0, 0, 0)

            }
            
        } else {
            controller.automaticallyAdjustsScrollViewInsets = false
        }
    }


   static func displayMessage(message : String) {
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButton(withTitle: "好的")
        alertView.cancelButtonIndex=0
        alertView.show()
        
    }
    
    static func dismissKeyboard(_ view: UIView) {
        view.endEditing(true)
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

extension UILabel {

    
    private func getLines1() -> Int {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        QL1("lines1: \(label.numberOfLines)")
        return label.numberOfLines
    }
    
    
    
}

extension UILabel {
    
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        
        
        // (Swift 4.1 and 4.0) Line spacing attribute
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}


class UITextViewPlaceHolder: UITextView, UITextViewDelegate {
    
    var originDelegate : UITextViewDelegate?
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.characters.count > 0
        }
        if originDelegate != nil {
            originDelegate?.textViewDidChange!(textView)
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.characters.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        
        originDelegate = self.delegate
        self.delegate = self
    }
    
}

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        
        // Swift 4.1 and below
        self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
    }
    
}
