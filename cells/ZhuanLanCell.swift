//
//  ZhuanLanCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/15.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import SnapKit

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
    
    override func updateConstraints() {
        titleLabel.snp.makeConstraints { (make) -> Void in
            //make.height.equalTo(latestLabel.snp.height).offset(3)
            make.left.equalTo(latestLabel.snp.left)
            make.right.equalTo(priceInfoLabel.snp.left).offset(1)
            make.top.equalTo(latestLabel.snp.top).offset(-20)
            
        }
        
        super.updateConstraints()
    }
    
    func update() {
        
        zhuanLanImageView.kf.setImage(with: URL(string: (zhuanLan?.imageUrl)!), placeholder: UIImage(named: "rect_placeholder"))
        zhuanLanImageView.clipsToBounds = true
        zhuanLanImageView.layer.cornerRadius = 5
        descLabel.text = zhuanLan?.desc
        priceInfoLabel.text = zhuanLan?.priceInfo
        updateTimeLabel.textAlignment = .center
        updateTimeLabel.text = "" + (zhuanLan?.updateTime)! + "  "
        updateTimeLabel.layer.cornerRadius = 5
        updateTimeLabel.clipsToBounds = true
        updateTimeLabel.sizeToFit()
        updateTimeLabel.frame.size.height += 2
        updateTimeLabel.frame.size.width += 2
        
        latestLabel.text = zhuanLan?.latest
        titleLabel.text = zhuanLan?.name
        
        if UIDevice().isIphone5Like() {
            updateConstraints()
            titleLabel.font = UIFont.systemFont(ofSize: 14)
        }
    }

}
