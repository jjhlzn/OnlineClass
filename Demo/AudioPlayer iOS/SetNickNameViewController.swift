//
//  SetNameViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/7.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class SetNickNameViewController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var loginUserStore = LoginUserStore()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var loading = LoadingOverlay()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.title = "昵称"
        saveButton.isEnabled = false
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldCell
        let loginUser = loginUserStore.getLoginUser()!
        cell.textField.text = loginUser.nickName
        print ("loginUser.nickName = \(loginUser.nickName)")
        cell.textField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        return cell
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if loginUserStore.getLoginUser()?.name != textField.text && textField.text?.length != 0 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    
    @IBAction func savePressed(sender: AnyObject) {
        
        loading.showOverlay(view: view)
        let request = SetNickNameRequest()
        request.newNickName = (tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! TextFieldCell).textField.text!
        BasicService().sendRequest(url: ServiceConfiguration.SET_NICK_NAME, request: request) {
            (resp : SetNickNameResponse) -> Void in
            self.loading.hideOverlayView()
            if resp.status != 0 {
                self.displayMessage(message: resp.errorMessage!)
                return
            }
            
            var loginUser = self.loginUserStore.getLoginUser()!
            loginUser.nickName = request.newNickName
            if self.loginUserStore.updateLoginUser() {
                loginUser = self.loginUserStore.getLoginUser()!
                print("nickname = \(loginUser.nickName)" )
                (self.navigationController?.viewControllers[1] as! PersonalInfoViewController).tableView.reloadData()
                self.navigationController?.popViewController(animated: true)
            } else {
                self.displayMessage(message: "保存失败")
                return
            }
            
        }
        
    }
    
}
