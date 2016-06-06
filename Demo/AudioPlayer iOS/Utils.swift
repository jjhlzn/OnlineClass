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

extension String {
    var length: Int {
        return characters.count
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