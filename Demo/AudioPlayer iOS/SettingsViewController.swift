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
    
    var loginUserStore = LoginUserStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return 48
        case 1:
            return 48
        case 2:
            return 66
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("accountSecurityCell")!
            cell.textLabel?.text = "重设密码"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("keyValueCell") as! KeyValueCell
            cell.nameLabel.text = "版本号"
            let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
            let appBundle = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
            
            cell.valueLabel.text = "\(version) (\(appBundle))"
            return cell
        case 2:
            return tableView.dequeueReusableCellWithIdentifier("logoutCell")!
        default:
            return tableView.dequeueReusableCellWithIdentifier("keyValueCell")!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 && row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            performSegueWithIdentifier("resetPasswordSegue", sender: nil)
        } else if section == 1 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell!.selectionStyle = .None
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    

    @IBAction func logoutPressed(sender: UIButton) {
        displayConfirmMessage("确认退出登录吗？", delegate: self)
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            
            BasicService().sendRequest(ServiceConfiguration.LOGOUT,request: LogoutRequest())  {
                (response : LogoutResponse) -> Void in
                self.loginUserStore.removeLoginUser()
                UserProfilePhotoStore().delete()
                self.performSegueWithIdentifier("logoutSegue", sender: nil)
            }
            
            break;
        case 1:
            break;
        default:
            break;
        }
    }

}
