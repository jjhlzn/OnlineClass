//
//  NewCommentCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/12.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import Kingfisher

class NewCommentCell: UITableViewCell {
    
    var comment : Comment?

    @IBOutlet weak var headImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        nameLabel.text = comment?.nickName
        //nameLabel.sizeToFit()
        timeLabel.text = comment?.time
        //timeLabel.sizeToFit()
        //commentLabel.numberOfLines = 0
        commentLabel.text = comment?.content.emojiUnescapedString
        //commentLabel.sizeToFit()
        
        Utils.setUserHeadImageView(headImageView, userId: (comment?.userId)!)
        
    }
}
