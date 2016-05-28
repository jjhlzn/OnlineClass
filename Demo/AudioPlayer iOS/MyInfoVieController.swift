//
//  MyInfoVieController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/22.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class MyInfoVieController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        BasicService().sendRequest(ServiceConfiguration.GET_CLIENT_NUBMER, request: GetClientNumberRequest()) {
            (resp: GetClientNumberResponse) -> Void in
            
            if resp.status == 0 {
                let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! MyInfoOtherCell
                cell.titleLabel.text = "我已推荐  \(resp.peopleCount)人"
            }
        }
        
    }
    
    

}

extension MyInfoVieController {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 4
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return 158
        case 1:
            return 48
        case 2:
            return 66
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("myInfoMainCell") as! MyInfoMainCell
            cell.userImage.becomeCircle()
           // cell.backgroundColor =
            //UIColor(red: 0xF2/255, green: 0x61/255, blue: 0, alpha: 0.9)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("myInfoOtherCell") as! MyInfoOtherCell
            var title = ""
            switch row {
            case 0:
                title = "个人资料"
                break
            case 1:
                title = "我已推荐  0人"
                break
            case 2:
                title = "消息中心"
                break
            case 3:
                title = "设置"
                break
            default:
                break
            }
            cell.titleLabel.text = title
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("logoutCell") as! logoutCell
            cell.viewController = self
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.selectionStyle = .None
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 1:
            switch row {
            case 3:
                performSegueWithIdentifier("settingSegue", sender: nil)
                break;
            default:
                break
            }
            break
        default:
            break
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

}
