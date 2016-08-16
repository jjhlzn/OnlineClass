//
//  PersonalInfoViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/28.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class PersonalInfoViewController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var loginUserStore : LoginUserStore!
    var loginUser : LoginUserEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        loginUserStore = LoginUserStore()
        loginUser = loginUserStore.getLoginUser()!
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        (self.navigationController?.viewControllers[0] as! MyInfoVieController).tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "姓名"
            cell.valueLabel.text = loginUser.name
            return cell
        
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "昵称"
            cell.valueLabel.text = loginUser.nickName
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "性别"
            if loginUser.sex == nil {
                cell.valueLabel.text = "保密"
            } else {
                cell.valueLabel.text = loginUser.sex!
            }
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "更多"
            cell.valueLabel.text = ""
            return cell
        
        default:
            return tableView.dequeueReusableCellWithIdentifier("personalItemCell")!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        switch row {
        case 0:
            performSegueWithIdentifier("setNameSegue", sender: nil)
            break
        case 1:
            performSegueWithIdentifier("setNickNameSegue", sender: nil)
            break
        case 2:
            performSegueWithIdentifier("setSexSegue", sender: nil)
            break
        case 3:
            performSegueWithIdentifier("moreSegue", sender: nil)
            break
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "moreSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            dest.title = "个人资料"
            dest.url = NSURL(string: ServiceLinkManager.PersonalInfoUrl)
        }
    }
    
    
}
