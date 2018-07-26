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
        
        setTextFieldHeight(field: phoneField, height: 45)
        setTextFieldHeight(field: passwordField, height: 45)
        setTextFieldHeight(field: phoneCheckCode, height: 45)
        setTextFieldHeight(field: otherPhoneField, height: 45)
        
        
        
        becomeLineBorder(field: phoneField)
        becomeLineBorder(field: passwordField)
        becomeLineBorder(field: phoneCheckCode)
        becomeLineBorder(field: otherPhoneField)
        
        phoneCodeLabel.isHidden = true
        
        
    }
    
    
    func addIconToField(field: UITextField, imageName: String) {
        let imageView = UIImageView();
        let image = UIImage(named: imageName);
        imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        view.addSubview(imageView)
        imageView.image = image;
        //field.leftView = imageView
        
        //field.leftViewMode = UITextFieldViewMode.Always
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
        paddingView.addSubview(imageView)
        field.leftView = paddingView;
        field.leftViewMode = UITextFieldViewMode.always
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
    
    @IBAction func signupPressed(_ sender: UIButton) {
        
        //验证手机号
        let phoneNumber = phoneField.text
        
        //验证验证码的格式
        let checkCode = phoneCheckCode.text
        
        //验证邀请人的手机号
        let otherPhone = otherPhoneField.text
        
        //验证密码的格式
        let password = passwordField.text
        
        //发送注册请求
        loadingOverlay.showOverlay(view: self.view)

        let request = SignupRequest(phoneNumber: phoneNumber!, checkCode: checkCode!, invitePhone: otherPhone!, password: password!)
        BasicService().sendRequest(url: ServiceConfiguration.SIGNUP, request: request) { (response: SignupResponse) -> Void in
            self.loadingOverlay.hideOverlayView()
            if response.status != 0 {
                self.displayMessage(message: response.errorMessage!)
            } else {
                self.displayMessage(message: "注册成功", delegate: self)
            }
            
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.performSegue(withIdentifier: "signupSuccessSegue", sender: nil)
    }
    
    @IBAction func showAgreementButtonPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "webViewSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webViewSegue" {
            let dest = segue.destination as! WebPageViewController
            dest.title = "知得APP服务协议"
            dest.url = NSURL(string: ServiceLinkManager.AgreementUrl)
        }
    }
 
    
}
