//
//  AnswerCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/9/7.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs

class AnswerCell: UITableViewCell {

    @IBOutlet weak var ct: UILabel!
    var answer : Answer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor =  UIColor.lightGray.withAlphaComponent(0.3)
    }

    
    func update() {
        //设置内容
        var content = answer!.fromUserName!
        if answer?.toUserName != nil {
            content = content + " 回复 " + answer!.toUserName!
        }
        content = content + " : " + answer!.content
        ct.text = content
        
        //设置contentLabel的高度
        var frame = ct.frame;
        ct.lineBreakMode = .byWordWrapping
        ct.numberOfLines = 0
        //contentLabel.setLineSpacing(lineSpacing: 0, lineHeightMultiple: 1)
        ct.sizeToFit()
        frame.size.height = ct.frame.height + 0
        ct.frame = frame
    }
    
    func getHeight() -> CGFloat {
        return ct.frame.size.height + 2
    }

}
