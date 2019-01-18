//
//  MobileLoginController.swift
//  AudioPlayer iOS
//  使用密码登陆
//
//  Created by 金军航 on 2018/11/28.
//  Copyright © 2018 tbaranes. All rights reserved.
//

import UIKit

class MobileLoginController: BaseUIViewController, UIAlertViewDelegate {
    
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var phoneCheckCode: UITextField!
    
    var loadingOverlay = LoadingOverlay()
    var loginUserStore = LoginUserStore()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        
        setTextFieldHeight(field: phoneField, height: 45)
        setTextFieldHeight(field: phoneCheckCode, height: 45)
        
        becomeLineBorder(field: phoneField)
        becomeLineBorder(field: phoneCheckCode)
        
        addIconToField(field: phoneField, imageName: "userIcon")
        addIconToField(field: phoneCheckCode, imageName: "password")
        
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
    
    
    func loginWithPassword() {
        let userName = (phoneField.text)!
        let password = (phoneCheckCode.text)!
        
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
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        loginWithPassword()
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        DispatchQueue.main.async { () -> Void in
            self.performSegue(withIdentifier: "signupSuccessSegue", sender: nil)
        }
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        DispatchQueue.main.async { () -> Void in
            self.performSegue(withIdentifier: "signupSegue", sender: nil)
        }
    }
    
    @IBAction func forgetPassowrdPressed(_ sender: Any) {
        DispatchQueue.main.async { () -> Void in
            self.performSegue(withIdentifier: "forgetPasswordSegue", sender: nil)
        }
    }
    
}
