//
//  ForgetPasswordViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: BaseUIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var phoneCheckCode: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneCodeLabel: UILabel!
    
    @IBOutlet weak var getPhoneCodeButton: UIButton!
    
    var loadingOverlay = LoadingOverlay()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        setTextFieldHeight(field: phoneField, height: 45)
        setTextFieldHeight(field: passwordField, height: 45)
        setTextFieldHeight(field: phoneCheckCode, height: 45)
        
        
        
        becomeLineBorder(field: phoneField)
        becomeLineBorder(field: passwordField)
        becomeLineBorder(field: phoneCheckCode)
        
        phoneCodeLabel.isHidden = true
    }

    @IBAction func getPhoneCodePressed(_ sender: UIButton) {
        //TODO: 验证手机号码
        //手机号码不能为空
        let phoneNumber = phoneField.text
        if phoneNumber == nil || phoneNumber == "" {
            displayMessage(message: "手机号不能为空")
            return
        }
        
        //手机号码的格式必须正确
        
        //发送请求
        let request = GetPhoneCheckCodeRequest(phoneNumber: phoneNumber!)
        BasicService().sendRequest(url: ServiceConfiguration.GET_PHONE_CHECK_CODE, request: request) { (response: GetPhoneCheckCodeResponse) -> Void in
            if response.status != 0 {
                self.displayMessage(message: response.errorMessage!)
            }
        }
        
        //设置timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateButtonTitle), userInfo: nil, repeats: true)
        
        getPhoneCodeButton.isHidden = true
        phoneCodeLabel.isHidden = false
    }
    
    var timerCount = 59
    var timer: Timer?
    @objc func updateButtonTitle() {
        phoneCodeLabel.text = "\(timerCount)秒后重新获取"
        timerCount = timerCount - 1
        if timerCount <= 0 {
            timer?.invalidate()
            getPhoneCodeButton.isHidden = false
            phoneCodeLabel.isHidden = true
            timerCount = 59
        }
    }
    
    
    @IBAction func confirmPressed(_ sender: UIButton) {
        
        //验证手机号码
        let phoneNumber = phoneField.text
        
        //验证验证码格式
        let phoneCode = phoneCheckCode.text
        
        //验证密码
        let password = passwordField.text
        
        loadingOverlay.showOverlay(view: view)
        let request = GetPasswordRequest(phoneNumber: phoneNumber!, checkCode: phoneCode!, password: password!)
        BasicService().sendRequest(url: ServiceConfiguration.GET_PASSWORD, request: request) { (response : GetPasswordResponse) -> Void in
            self.loadingOverlay.hideOverlayView()
            if response.status != 0 {
                self.displayMessage(message: response.errorMessage!)
                return
            }
            
            self.displayMessage(message: "密码修改成功", delegate: self)
        }
        
        
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        performSegue(withIdentifier: "backToLoginPageSegue", sender: nil)
    }


}
