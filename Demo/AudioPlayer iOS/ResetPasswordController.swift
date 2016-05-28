//
//  ResetPasswordController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/28.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class ResetPasswordController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var nameAndDescs = [["原密码", "请输入原来的密码"], ["新密码", "请输入新的密码"], ["确认密码", "请再次输入"]]
    
    @IBOutlet weak var tableView: UITableView!
    
    var loading =  LoadingOverlay()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("formCell") as! FormCell
        let row = indexPath.row
        
        cell.nameLabel.text = nameAndDescs[row][0]
        cell.valueField.placeholder = nameAndDescs[row][1]
        
        return cell
    }

    @IBAction func resetPasswordPressed(sender: AnyObject) {
        
        if !checkBeforeSubmit() {
            return
        }
        
        let originPassword = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as!FormCell).valueField.text!
        let newPassword = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as!FormCell).valueField.text!
        
        let request = ResetPasswordRequest(oldPassword: originPassword, newPassword: newPassword)
        loading.showOverlay(view)
        BasicService().sendRequest(ServiceConfiguration.RESET_PASSWORD, request: request) {
            (resp : ResetPasswordResponse) -> Void in
            self.loading.hideOverlayView()
            if resp.status != 0 {
                self.displayMessage(resp.errorMessage!)
                return
            }
            
            self.displayMessage("密码修改成功")
        }
    }
    
    private func checkBeforeSubmit() -> Bool  {
        
        let originPassword = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as!FormCell).valueField.text!
        let newPassword = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as!FormCell).valueField.text!
        let newPassword2 = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as!FormCell).valueField.text!
        
        if originPassword.length == 0 {
            displayMessage("原密码不能为空")
            return false
        }
        
        if newPassword.length == 0 {
            displayMessage("新密码不能为空")
            return false
        }

        
        if newPassword2.length == 0 {
            displayMessage("新密码不能为空")
            return false
        }
        
        if newPassword != newPassword2 {
            displayMessage("两次输入的新密码不一样")
            return false
        }


        
        return true
        
    }
    
    
}
