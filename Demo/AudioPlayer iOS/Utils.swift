//
//  Utils.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit


class Utils {
    static func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
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