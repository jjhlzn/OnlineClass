//
//  ZhuanLanCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/15.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class ZhuanLanCell: UITableViewCell {
    
    var zhuanLan : ZhuanLan?
    
    @IBOutlet weak var zhuanLanImageView: UIImageView!
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var priceInfoLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var latestLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
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
        descLabel.text = zhuanLan?.desc
        priceInfoLabel.text = zhuanLan?.priceInfo
        updateTimeLabel.text = " " + (zhuanLan?.updateTime)! + " "
        updateTimeLabel.layer.cornerRadius = 5
        updateTimeLabel.clipsToBounds = true
        updateTimeLabel.sizeToFit()
        latestLabel.text = zhuanLan?.latest
        titleLabel.text = zhuanLan?.name
    }

}
