//
//  MyInfoMainCell.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/22.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class MyInfoMainCell: UITableViewCell {

    @IBOutlet weak var bossLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userInfoLabel: UILabel!
}



class MyInfoOtherCell : UITableViewCell {
    
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var otherInfoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
}


class MyInfoSecondLineCell : UITableViewCell {
    @IBOutlet weak var jifenLabel: UILabel!
    @IBOutlet weak var chaifuLabel: UILabel!
    @IBOutlet weak var tuanduiLabel: UILabel!
}