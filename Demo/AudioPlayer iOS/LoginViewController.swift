//
//  LoginViewController.swift
//  OnlineClass
//  使用验证码登陆
//
//  Created by 刘兆娜 on 16/4/23.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import Foundation
import QorumLogs
import SnapKit

class LoginViewController: BaseUIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logImage: UIImageView!
    
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    var isKeyboardShow = false
    
    @IBOutlet weak var weixinViewContainer: UIView!
    @IBOutlet weak var weixinLoginBtn: UIImageView!
    
    @IBOutlet weak var weixinLoginLabel: UILabel!
    @IBOutlet weak var mobileLoginBtn: UIImageView!
    
    @IBOutlet weak var mobileLoginLabel: UILabel!
    @IBOutlet weak var phoneCodeLabel: UILabel!
    @IBOutlet weak var getPhoneCodeButton: UIButton!
    
    var weixinLoginManager : WeixinLoginManager!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        weixinLoginManager = WeixinLoginManager()
        setTextFieldHeight(field: userNameField, height: 45)
        setTextFieldHeight(field: passwordField, height: 45)
        
        becomeLineBorder(field: userNameField)
        becomeLineBorder(field: passwordField)
        
        addIconToField(field: userNameField, imageName: "userIcon")
        addIconToField(field: passwordField, imageName: "password")
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let screenHeight = screenSize.height
        if screenHeight < 667 {
            //TODO: 参数
            NotificationCenter.default.addObserver(self,
                                                           selector: #selector(keyboardWillShow),
                                                           name: NSNotification.Name.UIKeyboardWillShow,
                                                           object: nil)
            NotificationCenter.default.addObserver(self,
                                                           selector: #selector(keyboardWillHide),
                                                           name: NSNotification.Name.UIKeyboardWillHide,
                                                           object: nil)
        }
        
        setupOtherLoginView()
        
        phoneCodeLabel.isHidden = true
       
    }
    
    
    func setupOtherLoginView() {
        if UIDevice().isX() {
            weixinViewContainer.frame.origin.y -= 20
        }
        
        weixinLoginBtn.isUserInteractionEnabled = true
        
        //var tapWeixinLogin = UITapGestureRecognizer(target: self, action: #selector(tapWeixinLogin))
        weixinLoginBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapWeixinLogin)))
        
        mobileLoginBtn.isUserInteractionEnabled = true
        
        //var tapWeixinLogin = UITapGestureRecognizer(target: self, action: #selector(tapWeixinLogin))
        mobileLoginBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMobileLogin)))
        
        if WXApi.isWXAppInstalled() {
            setupOtherLoginViewWithWeixin()
        } else {
            setupOtherLoginViewWithoutWeixin()
        }
    }
    
    func setupOtherLoginViewWithWeixin() {
        weixinLoginBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview().offset(10)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        weixinLoginLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(weixinLoginBtn)
            make.centerY.equalTo(weixinLoginBtn).offset(36)
        }
        
        mobileLoginBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview().offset(30)
            make.centerY.equalToSuperview().offset(10)
            make.width.equalTo(43)
            make.height.equalTo(43)
            
        }
        
        mobileLoginLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(mobileLoginBtn)
            make.centerY.equalTo(mobileLoginBtn).offset(36)
        }
    }
    
    func setupOtherLoginViewWithoutWeixin() {
        weixinLoginBtn.isHidden = true
        weixinLoginLabel.isHidden = true
        
        mobileLoginBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(10)
            make.width.equalTo(43)
            make.height.equalTo(43)
            
        }
        
        mobileLoginLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(mobileLoginBtn)
            make.centerY.equalTo(mobileLoginBtn).offset(36)
        }
    }
    
    @IBAction func getPhoneCodePressed(_ sender: UIButton) {
        //手机号码不能为空
        let phoneNumber = userNameField.text
        if phoneNumber == nil || phoneNumber == "" {
            displayMessage(message: "手机号不能为空")
            return
        }
        
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
    
    @objc func tapMobileLogin(_ tapGes : UITapGestureRecognizer) {
        QL1("tapMobileLogin called")
        performSegue(withIdentifier: "mobileLoginSegue", sender: nil)
    }
    
    @objc func tapWeixinLogin(_ tapGes : UITapGestureRecognizer) {
        QL1("tapWeixinLogin called")
        weixinLoginManager.loginStep1()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let screenSize: CGRect = UIScreen.main.bounds

        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        print("width = \(screenWidth), height = \(screenHeight)")

        if screenHeight < 667 {
            
            NotificationCenter.default.removeObserver(self,  name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self,  name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    
    override func isNeedResetAudioPlayerDelegate() -> Bool {
        return false
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
    
    
    var originFrame: CGRect?
    var originCenter: CGPoint?
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if !isKeyboardShow {
            view.frame.origin.y -= 35
            var frame = logImage.frame
            originFrame = logImage.frame
            frame.size.width = 90
            frame.size.height = 90
            originCenter = logImage.center
            logImage.frame = frame
            logImage.center.x = originCenter!.x
            logImage.center.y = originCenter!.y + 10
            isKeyboardShow = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if isKeyboardShow {
            isKeyboardShow = false
        
            view.frame.origin.y += 35
            logImage.frame = originFrame!
            logImage.center = originCenter!
        }
    }
    
    func showLoadingOverlay() {
        self.loadingOverlay.showOverlay(view: self.view)
    }
    
    func hideLoadingOverlay() {
        self.loadingOverlay.hideOverlayView()
    }
    
    var loadingOverlay = LoadingOverlay()
    var loginUserStore = LoginUserStore()
    
    func loginWithCheckCode() {
        //验证手机号
        let phoneNumber = userNameField.text
        
        //验证验证码的格式
        let checkCode = passwordField.text
        
        
        
        if phoneNumber == nil || phoneNumber == "" {
            displayMessage(message: "手机号不能为空")
            return
        }
        
        if checkCode == nil || checkCode == "" {
            displayMessage(message: "验证码不能为空")
            return
        }
        
        //发送注册请求
        loadingOverlay.showOverlay(view: self.view)
        
        let request = MobileLoginRequest(userName: phoneNumber!,  checkCode: checkCode!,
                                         deviceToken: (UIApplication.shared.delegate as! AppDelegate).deviceTokenString)
        BasicService().sendRequest(url:  ServiceConfiguration.MOBILE_LOGIN, request: request) { (response: MobileLoginResponse) -> Void in
            DispatchQueue.main.async() {
                self.loadingOverlay.hideOverlayView()
                if response.status == 0 {
                    let loginUser = LoginUser()
                    loginUser.userName = phoneNumber!
                    loginUser.password = "loginwithmobilecheckcode"
                    loginUser.name = response.name!
                    loginUser.sex = response.sex
                    loginUser.codeImageUrl = response.codeImageUrl
                    loginUser.token = response.token!
                    loginUser.nickName = response.nickName
                    loginUser.level = response.level
                    loginUser.boss = response.boss
                    if self.loginUserStore.saveLoginUser(loginUser: loginUser) {
                        DispatchQueue.main.async { () -> Void in
                            self.performSegue(withIdentifier: "loginSuccessSegue", sender: self)
                        }
                    } else {
                        self.displayMessage(message: "登录失败")
                    }
                } else {
                    self.displayMessage(message: response.errorMessage!)
                }
                
            }
            
        }
    }
    
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        
       
        loginWithCheckCode()
    }


    
}
