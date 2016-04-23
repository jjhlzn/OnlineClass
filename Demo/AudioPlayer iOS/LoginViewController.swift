//
//  LoginViewController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/23.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import Foundation


class LoginViewController: BaseUIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logImage: UIImageView!
    
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    var isKeyboardShow = false
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        
        var frameRect = userNameField.frame
        frameRect.size.height = 45
        userNameField.frame = frameRect
        
        var frameRect1 = passwordField.frame
        frameRect1.size.height = 45
        passwordField.frame = frameRect1

        
        becomeLineBorder(userNameField)
        becomeLineBorder(passwordField)
        
        addIconToField(userNameField, imageName: "userIcon")
        addIconToField(passwordField, imageName: "password")
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        print("width = \(screenWidth), height = \(screenHeight)")
        if screenHeight < 667 {
        
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentListController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentListController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        }
        
    }
    
    func becomeLineBorder(field: UITextField) {
        field.borderStyle = .None
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, field.frame.size.height - 1, field.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        field.layer.addSublayer(bottomBorder)
    }
    
    func addIconToField(field: UITextField, imageName: String) {
        let imageView = UIImageView();
        let image = UIImage(named: imageName);
        imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        view.addSubview(imageView)
        imageView.image = image;
        field.leftView = imageView
        
        field.leftViewMode = UITextFieldViewMode.Always
    }
    
    
    var originFrame: CGRect?
    var originCenter: CGPoint?
    func keyboardWillShow(notification: NSNotification) {
        
        if !isKeyboardShow {
            view.frame.origin.y -= 65
            
            var frame = logImage.frame
            originFrame = logImage.frame
            frame.size.width = 70
            frame.size.height = 70
            originCenter = logImage.center
            logImage.frame = frame
            logImage.center.x = originCenter!.x
            logImage.center.y = originCenter!.y + 10
        }
        isKeyboardShow = true
        
    }
    
    
    
    func keyboardWillHide(notification: NSNotification) {
        isKeyboardShow = false

        view.frame.origin.y += 65
        logImage.frame = originFrame!
        logImage.center = originCenter!
    }

    
}
