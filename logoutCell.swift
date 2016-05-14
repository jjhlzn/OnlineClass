//
//  logoutCell.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class logoutCell: UITableViewCell {
    
    var viewController: UIViewController?

    @IBAction func logout(sender: UIButton) {
        viewController?.performSegueWithIdentifier("logoutSegue", sender: nil)
    }
}
