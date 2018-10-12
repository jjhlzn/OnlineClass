//
//  CourseOverviewCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/11.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import SnapKit

class CourseOverviewCell: UITableViewCell {
    var song : LiveSong?
    @IBOutlet weak var overview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func updateConstraints() {
      
        overview.snp.makeConstraints { (make) -> Void in
            //make.width.equalTo(sceenWidth )
            //make.height.equalTo(sceenWidth / 375 * 177)
            
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(0)
            //make.height.equalToSuperview()
            
            
            overview.numberOfLines = 0
            //overview.backgroundColor = UIColor.red
            overview.sizeToFit()
            
            //overview.sizeThatFits(<#T##size: CGSize##CGSize#>)
        }
        
        super.updateConstraints()
    }
    
    func update() {
        overview.text = song?.introduction
        //overview.sizeToFit()
        updateConstraints()
    }
    
}
