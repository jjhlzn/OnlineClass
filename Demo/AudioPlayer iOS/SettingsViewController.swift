//
//  SettingsViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class SettingsViewController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var keyValueStore = KeyValueStore()
    var loginUserStore = LoginUserStore()
    var weixinLoginManager : WeixinLoginManager!
    var loadingOverlay : LoadingOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        loadingOverlay = LoadingOverlay()
        weixinLoginManager = WeixinLoginManager()
        
        Utils.setNavigationBarAndTableView(self, tableView: tableView)
        setLeftBackButton()
    }
    
    func showLoadingOverlay() {
        self.loadingOverlay.showOverlay(view: self.view)
    }
    
    func hideLoadingOverlay() {
        self.loadingOverlay.hideOverlayView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0, 1, 2, 3:
            return 48
        case 4:
            return 60
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "bindWeixin") as! BindWeixinCell
            if keyValueStore.hasBindPhone() {
                cell.nameLabel.text = "手机号 (" + loginUserStore.getLoginUser()!.userName! + ")"
                cell.descLabel.text = "重新绑定"
            } else {
                cell.nameLabel.text = "手机号"
                cell.descLabel.text = "尚未绑定"
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "bindWeixin") as! BindWeixinCell
            cell.nameLabel.text = "微信登录"
            if keyValueStore.isBindWeixin() {
                cell.descLabel.text = "重新绑定"
            } else {
                cell.descLabel.text = "尚未绑定"
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountSecurityCell")!
            cell.textLabel?.text = "重设密码"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "keyValueCell") as! KeyValueCell
            cell.nameLabel.text = "版本号"
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let appBundle = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
            
            cell.valueLabel.text = "\(version) (\(appBundle))"
            return cell
        case 4:
            return tableView.dequeueReusableCell(withIdentifier: "logoutCell")!
        default:
            return tableView.dequeueReusableCell(withIdentifier: "keyValueCell")!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 && row == 0 {
            performSegue(withIdentifier: "bindPhoneSegue", sender: nil)
        }
         else if section == 1 && row == 0 {
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
            weixinLoginManager.bindWeixin()
         } else if section == 2 && row == 0 {
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
            performSegue(withIdentifier: "resetPasswordSegue", sender: nil)
        } else if section == 3 {
            let cell = tableView.cellForRow(at: indexPath as IndexPath)
            cell!.selectionStyle = .none
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    

    @IBAction func logoutBtnPressed(_ sender: Any) {
        displayConfirmMessage(message: "确认退出登录吗？", delegate: self)
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            
            BasicService().sendRequest(url: ServiceConfiguration.LOGOUT,request: LogoutRequest())  {
                (response : LogoutResponse) -> Void in
                self.loginUserStore.removeLoginUser()
                self.performSegue(withIdentifier: "logoutSegue", sender: nil)
            }
            
            break;
        case 1:
            break;
        default:
            break;
        }
    }

}
