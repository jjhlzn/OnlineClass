//
//  MyInfoCommonCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/17.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class MyInfoCommonCell: UITableViewCell {

    var lineInfo = [String]()
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var bottomLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        iconImageView.image = UIImage(named: lineInfo[0])
        nameLabel.text = lineInfo[1]
        descLabel.text = ""
        
        if lineInfo[4] == "0" {
            bottomLine.isHidden = true
        } else {
            let frame = bottomLine.frame
            let newFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 0.5)
            bottomLine.frame = newFrame
            bottomLine.isHidden = false
        }
        
        let store = KeyValueStore()
        if lineInfo[5] != "" {
            if lineInfo[5] == KeyValueStore.key_zhidian && LoginManager().isAnymousUser(LoginUserStore().getLoginUser()!) {
                descLabel.text = "\(WalletManager().getBalance())知点"
            } else {
                descLabel.text = store.get(key: lineInfo[5], defaultValue: "")
            }
            
        }
    }

}
