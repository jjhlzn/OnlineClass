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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "姓名"
            cell.valueLabel.text = LoginUserStore().getLoginUser()?.name
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "性别"
            if LoginUserStore().getLoginUser()?.sex == nil {
                cell.valueLabel.text = "保密"
            } else {
                cell.valueLabel.text = LoginUserStore().getLoginUser()?.sex!
            }
            return cell
        
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("personalItemCell2") as! PersonalInfoCell2
            cell.nameLabel.text = "我的二维码"
            cell.rightImage = UIImageView(image: UIImage(named: "barcode"))
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
            performSegueWithIdentifier("setSexSegue", sender: nil)
            break
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
}
