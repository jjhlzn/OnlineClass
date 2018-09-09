//
//  NewAlbumCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/15.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class NewAlbumCell: UITableViewCell {
    
    var course : Album?

    @IBOutlet weak var courseImageView: UIImageView!
    
    /*
    @IBOutlet weak var star0: UIImageView!
    
    @IBOutlet weak var star1: UIImageView!
    
    @IBOutlet weak var star2: UIImageView!
    
    @IBOutlet weak var star3: UIImageView!
    
    @IBOutlet weak var star4: UIImageView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel! */
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var liveTimeLabel: UILabel!
    
    @IBOutlet weak var listenerCountLabel: UILabel!
    

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        courseImageView.kf.setImage(with: URL(string: (course?.image)!))
        courseImageView.layer.cornerRadius = 5
        courseImageView.clipsToBounds = true
        
        /*
        var stars = (course?.stars)!
        var starImageViews = [UIImageView]()
        starImageViews.append(star0)
        starImageViews.append(star1)
        starImageViews.append(star2)
        starImageViews.append(star3)
        starImageViews.append(star4)
        for index in 0...4 {
            var imageName = "star1"
            if stars >= 1 {
                imageName = "star1"
            } else if stars <= 0 {
                imageName = "star2"
            } else {
                imageName = "star3"
            }
            starImageViews[index].image = UIImage(named: imageName)
            stars -= 1
        }
        
        scoreLabel.text = "\((course?.stars)!)"
        scoreLabel.sizeToFit()
        nameLabel.text = course?.name
        dateLabel.text = course?.date
        
        */
        
        
        if course?.status == "" {
            course?.status = "未开始"
        }
        statusLabel.text = course?.status
        
        listenerCountLabel.text = "\((course?.listenCount)!)人在线"
        listenerCountLabel.sizeToFit()
        if course?.liveTime == "" {
            course?.liveTime = "时间未定"
        }
        liveTimeLabel.text = course?.liveTime
        
    }

}
