//
//  SignupViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/13.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController : BaseUIViewController, UIAlertViewDelegate {
    
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneCheckCode: UITextField!
    @IBOutlet weak var otherPhoneField: UITextField!
    
    @IBOutlet weak var phoneCodeLabel: UILabel!
    @IBOutlet weak var getPhoneCodeButton: UIButton!
    var loadingOverlay = LoadingOverlay()
    
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
        
        phoneCodeLabel.hidden = true
        
        
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
        let request = GetPhoneCheckCodeRequest(phoneNumber: phoneNumber!)
        BasicService().sendRequest(ServiceConfiguration.GET_PHONE_CHECK_CODE, request: request) { (response: GetPhoneCheckCodeResponse) -> Void in
            if response.status != 0 {
                self.displayMessage(response.errorMessage!)
            }
        }
        
        //设置timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateButtonTitle), userInfo: nil, repeats: true)
        
        getPhoneCodeButton.hidden = true
        phoneCodeLabel.hidden = false
    }
    
    var timerCount = 59
    var timer: NSTimer?
    func updateButtonTitle() {
        phoneCodeLabel.text = "\(timerCount)秒后重新获取"
        timerCount = timerCount - 1
        if timerCount <= 0 {
            timer?.invalidate()
            getPhoneCodeButton.hidden = false
            phoneCodeLabel.hidden = true
            timerCount = 59
        }
    }
    
    @IBAction func signupPressed(sender: UIButton) {
        
        //验证手机号
        let phoneNumber = phoneField.text
        
        //验证验证码的格式
        let checkCode = phoneCheckCode.text
        
        //验证邀请人的手机号
        let otherPhone = otherPhoneField.text
        
        //验证密码的格式
        let password = passwordField.text
        
        //发送注册请求
        loadingOverlay.showOverlay(self.view)

        let request = SignupRequest(phoneNumber: phoneNumber!, checkCode: checkCode!, invitePhone: otherPhone!, password: password!)
        BasicService().sendRequest(ServiceConfiguration.SIGNUP, request: request) { (response: SignupResponse) -> Void in
            self.loadingOverlay.hideOverlayView()
            if response.status != 0 {
                self.displayMessage(response.errorMessage!)
            } else {
                self.displayMessage("注册成功", delegate: self)
            }
            
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.performSegueWithIdentifier("signupSuccessSegue", sender: nil)
    }
    
    @IBAction func showAgreementButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("webViewSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "webViewSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            dest.title = "巨方助手APP服务协议"
            dest.url = NSURL(string: ServiceLinkManager.AgreementUrl)
        }
    }
 
    
}