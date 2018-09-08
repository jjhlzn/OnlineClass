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
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    var toutiao : FinanceToutiao?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func update() {
        contentLabel.text = toutiao!.content
        
        var tagStr = ""
        if toutiao!.index == 0 {
            tagStr = "TOP 1"
        } else if toutiao!.index == 1 {
            tagStr = "TOP 2"
        } else if toutiao!.index == 2 {
            tagStr = "TOP 3"
        }
        
        if tagStr != "" {
            tagLabel.isHidden = false
            tagImage.isHidden = true
        } else {
            tagLabel.isHidden = true
            tagImage.isHidden = false
        }
        
        tagLabel.text = tagStr
    }

}
