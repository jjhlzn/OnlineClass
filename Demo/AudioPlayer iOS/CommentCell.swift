//
//  CommentCell.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/19.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!

    @IBOutlet weak var userIdLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    var contentLabelHeight: CGFloat?
}
