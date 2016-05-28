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
            cell.valueLabel.text = "张三"
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "性别"
            cell.valueLabel.text = "男"
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
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
}
