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
    @IBOutlet weak var phoneCodeLabel: UILabel!
    
    @IBOutlet weak var getPhoneCodeButton: UIButton!
    
    var loadingOverlay = LoadingOverlay()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        setTextFieldHeight(phoneField, height: 45)
        setTextFieldHeight(passwordField, height: 45)
        setTextFieldHeight(phoneCheckCode, height: 45)
        
        
        
        becomeLineBorder(phoneField)
        becomeLineBorder(passwordField)
        becomeLineBorder(phoneCheckCode)
        
        phoneCodeLabel.hidden = true
    }

    @IBAction func getPhoneCodePressed(sender: UIButton) {
        //TODO: 验证手机号码
        //手机号码不能为空
        let phoneNumber = phoneField.text
        if phoneNumber == nil || phoneNumber == "" {
            displayMessage("手机号不能为空")
            return
        }
        
        //手机号码的格式必须正确
        
        //发送请求
        let params = ["phoneNumber": phoneNumber!]
        BasicService().sendRequest(ServiceConfiguration.GET_PHONE_CHECK_CODE, params: params) { (response: GetPhoneCheckCodeResponse) -> Void in
            if response.status != 0 {
                self.displayMessage(response.errorMessage!)
            }
        }
        
        //设置timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateButtonTitle", userInfo: nil, repeats: true)
        
        getPhoneCodeButton.hidden = true
        phoneCodeLabel.hidden = false
    }
    
    var timerCount = 59
    var timer: NSTimer?
    func updateButtonTitle() {
        phoneCodeLabel.text = "\(timerCount)秒后重新获取"
        timerCount = timerCount - 1
        if timerCount == 0 {
            timer?.invalidate()
            getPhoneCodeButton.hidden = false
            phoneCodeLabel.hidden = true
        }
    }
    
    
    @IBAction func confirmPressed(sender: UIButton) {
        
        //验证手机号码
        let phoneNumber = phoneField.text
        
        //验证验证码格式
        let phoneCode = phoneCheckCode.text
        
        //验证密码
        let password = passwordField.text
        
        let params = ["phoneNumber": phoneNumber!, "checkCode": phoneCode!, "password": password!]
        
        loadingOverlay.showOverlay(view)
        BasicService().sendRequest(ServiceConfiguration.GET_PASSWORD, params: params) { (response : GetPasswordResponse) -> Void in
            self.loadingOverlay.hideOverlayView()
            if response.status != 0 {
                self.displayMessage(response.errorMessage!)
            }
        }
        
        
        
    }


}
