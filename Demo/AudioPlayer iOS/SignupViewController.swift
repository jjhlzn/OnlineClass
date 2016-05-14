//
//  SignupViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/13.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController : BaseUIViewController {
    
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneCheckCode: UITextField!
    @IBOutlet weak var otherPhoneField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        
        setTextFieldHeight(phoneField, height: 45)
        setTextFieldHeight(passwordField, height: 45)
        setTextFieldHeight(phoneCheckCode, height: 45)
        setTextFieldHeight(otherPhoneField, height: 45)
        
        
        
        becomeLineBorder(phoneField)
        becomeLineBorder(passwordField)
        becomeLineBorder(phoneCheckCode)
        becomeLineBorder(otherPhoneField)
        
        //addIconToField(phoneField, imageName: "userIcon")
        //addIconToField(passwordField, imageName: "password")

        
    }
    
    
    func addIconToField(field: UITextField, imageName: String) {
        let imageView = UIImageView();
        let image = UIImage(named: imageName);
        imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        view.addSubview(imageView)
        imageView.image = image;
        //field.leftView = imageView
        
        //field.leftViewMode = UITextFieldViewMode.Always
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 40, 25))
        paddingView.addSubview(imageView)
        field.leftView = paddingView;
        field.leftViewMode = UITextFieldViewMode.Always
    }

    
}