//
//  BindPhoneViewController.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/10/23.
//  Copyright © 2018 tbaranes. All rights reserved.
//

import Foundation
import UIKit

class BindPhoneViewController : BaseUIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var repeatPhoneField: UITextField!
    @IBOutlet weak var phoneCheckCode: UITextField!
 
    @IBOutlet weak var phoneCodeLabel: UILabel!
    @IBOutlet weak var getPhoneCodeButton: UIButton!

    var loadingOverlay = LoadingOverlay()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        
        setTextFieldHeight(field: phoneField, height: 45)
        setTextFieldHeight(field: phoneCheckCode, height: 45)
        setTextFieldHeight(field: repeatPhoneField, height: 45)
        
        
        
        becomeLineBorder(field: phoneField)
        becomeLineBorder(field: phoneCheckCode)
        becomeLineBorder(field: repeatPhoneField)
        
        phoneCodeLabel.isHidden = true
        
        if !KeyValueStore().hasBindPhone() {
            phoneCheckCode.isHidden = true
            getPhoneCodeButton.isHidden = true
        }
        
        setLeftBackButton()
        
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
        let phoneNumber = LoginUserStore().getLoginUser()!.userName!
        
        //发送请求
        let request = GetPhoneCheckCodeRequest(phoneNumber: phoneNumber)
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
    
    @IBAction func submitPressed(_ sender: UIButton) {
        
        //验证手机号
        let phoneNumber = phoneField.text
        
        //验证邀请人的手机号
        let otherPhone = repeatPhoneField.text
        
        //验证验证码的格式
        let checkCode = phoneCheckCode.text
        
        if phoneNumber?.isEmpty ?? false {
            self.displayMessage(message: "手机号不能为空")
            return
        }
        
        if phoneNumber != otherPhone {
            self.displayMessage(message: "两次输入的手机号不一致")
            return
        }
        
        if KeyValueStore().hasBindPhone() {
            if checkCode?.isEmpty ?? false {
                self.displayMessage(message: "验证码不能为空")
                return
            }
        }
        
        loadingOverlay.showOverlay(view: self.view)
        
        let request = BindPhoneRequest()
        request.newPhone = phoneNumber
        request.code = checkCode
        BasicService().sendRequest(url: ServiceConfiguration.BIND_PHONE, request: request) { (response: BindPhoneResponse) -> Void in
            self.loadingOverlay.hideOverlayView()
            if response.status != 0 {
                self.displayMessage(message: response.errorMessage!)
                return
            }
            
            let loginUserStore = LoginUserStore()
            let loginUser = self.createLoginUser(loginUserStore.getLoginUser()!)
            loginUser.userName = request.newPhone
            _ = loginUserStore.saveLoginUser(loginUser: loginUser)
            
            KeyValueStore().save(key: KeyValueStore.key_hasbindphone, value: "1")
            self.displayMessage(message: "绑定成功", delegate: self)
        }
        
    }
    
    
    func createLoginUser(_  entity: LoginUserEntity) -> LoginUser {
        let loginUser = LoginUser()
        loginUser.userName = entity.userName
        loginUser.password = entity.password
        loginUser.name = entity.name
        loginUser.sex = entity.sex
        loginUser.codeImageUrl = entity.codeImageUrl
        loginUser.token = entity.token
        loginUser.nickName = entity.nickName
        loginUser.level = entity.level
        loginUser.boss = entity.boss
        
        return loginUser
    }
    
}
