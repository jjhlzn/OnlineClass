//
//  BindWeixinCellTableViewCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/10/20.
//  Copyright © 2018 tbaranes. All rights reserved.
//

import UIKit

class BindWeixinCell : UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
