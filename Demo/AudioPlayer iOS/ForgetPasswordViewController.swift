//
//  ForgetPasswordViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: BaseUIViewController {
    
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var phoneCheckCode: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        setTextFieldHeight(phoneField, height: 45)
        setTextFieldHeight(passwordField, height: 45)
        setTextFieldHeight(phoneCheckCode, height: 45)
        
        
        
        becomeLineBorder(phoneField)
        becomeLineBorder(passwordField)
        becomeLineBorder(phoneCheckCode)
    }

}
