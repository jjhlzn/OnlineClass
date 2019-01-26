//
//  CourseOverviewHeaderCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/11.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class CourseOverviewHeaderCell: UITableViewCell {
    var song : Song?
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        nameLabel.text = song?.name
    }
}
