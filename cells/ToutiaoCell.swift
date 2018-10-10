//
//  ToutiaoCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/9/8.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class ToutiaoCell: UITableViewCell {
    
    @IBOutlet weak var tagImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    var toutiao : FinanceToutiao?
    var isLast = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func update() {
        contentLabel.text = toutiao!.content

    
    }

}
