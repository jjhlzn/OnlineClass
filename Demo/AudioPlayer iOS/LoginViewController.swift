//
//  LoginViewController.swift
//  OnlineClass
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
        
        
        
        if WXApi.isWXAppInstalled() {
            if UIDevice().isX() {
                weixinViewContainer.frame.origin.y -= 40
            }
            
            weixinLoginBtn.isUserInteractionEnabled = true
            
            //var tapWeixinLogin = UITapGestureRecognizer(target: self, action: #selector(tapWeixinLogin))
            weixinLoginBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapWeixinLogin)))
        } else {
            weixinViewContainer.isHidden = true
        }
        
       
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
    @IBAction func loginButtonPressed(sender: UIButton) {
        
        let userName = (userNameField.text)!
        let password = (passwordField.text)!
        
        if userName.isEmpty || password.isEmpty {
            displayMessage(message: "用户名和密码不能为空")
            return
        }
        
        loadingOverlay.showOverlay(view: self.view)
        
        let request = LoginRequest(userName: userName, password: password, deviceToken: (UIApplication.shared.delegate as! AppDelegate).deviceTokenString)
        BasicService().sendRequest(url:  ServiceConfiguration.LOGIN, request: request) { (response: LoginResponse) -> Void in
            DispatchQueue.main.async() {
                self.loadingOverlay.hideOverlayView()
                if response.status == 0 {
                        let loginUser = LoginUser()
                        loginUser.userName = userName
                        loginUser.password = password
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


    
}
