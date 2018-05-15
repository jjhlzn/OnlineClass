//
//  ZhuanLanCell2.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/15.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class ZhuanLanCell2: UITableViewCell {
    var zhuanLan : ZhuanLan?
    
    @IBOutlet weak var zhuanLanImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var latestLabel: UILabel!
    
    @IBOutlet weak var priceInfoLabel: UILabel!
    @IBOutlet weak var dingyueLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        zhuanLanImageView.kf.setImage(with: URL(string: (zhuanLan?.imageUrl)!))
        zhuanLanImageView.clipsToBounds = true
        zhuanLanImageView.layer.cornerRadius = 5
        priceInfoLabel.text = zhuanLan?.priceInfo
        authorLabel.text = "\((zhuanLan?.author)!)   \((zhuanLan?.authorTitle)!)"
        nameLabel.text = zhuanLan?.name
        latestLabel.text = zhuanLan?.latest
        dingyueLabel.text = "\((zhuanLan?.dingyue)!)人订阅"
    }

}
