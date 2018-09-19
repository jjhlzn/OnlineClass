//
//  NewAlbumCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/15.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import QorumLogs

class NewAlbumCell: UITableViewCell {
    
    var course : Album?

    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var labelsContainer: UIView!
    
    /*
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var liveTimeLabel: UILabel!
    @IBOutlet weak var listenerCountLabel: UILabel! */
    
    var statusImage: UIImageView!
    var statusLabel : UILabel!
    var listenerImage : UIImageView!
    var listenerLabel : UILabel!
    var timeImage : UIImageView!
    var timeLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        makeLabels()
        makeImages()
    }
    
    private func makeLabels() {
        statusLabel = UILabel()
        statusLabel.font = statusLabel.font.withSize(11)
        statusLabel.textAlignment = .left
        //statusLabel.backgroundColor = UIColor.black
        statusLabel.textColor = UIColor.black
        statusLabel.text = ""
        
        labelsContainer.addSubview(statusLabel)
        
        listenerLabel = UILabel()
        listenerLabel.font = statusLabel.font.withSize(11)
        listenerLabel.textAlignment = .left
        //listenerLabel.backgroundColor = UIColor.black
        listenerLabel.textColor = UIColor.black
        listenerLabel.text = ""
        
        labelsContainer.addSubview(listenerLabel)
        
        timeLabel = UILabel()
        timeLabel.font = statusLabel.font.withSize(11)
        timeLabel.textAlignment = .right
        //timeLabel.backgroundColor = UIColor.black
        timeLabel.textColor = UIColor.black
        timeLabel.text = ""
        
        labelsContainer.addSubview(timeLabel)
    }
    
    private func makeImages() {
        statusImage = UIImageView(image: UIImage(named: "play1"))
        labelsContainer.addSubview(statusImage)
        
        listenerImage = UIImageView(image: UIImage(named: "u"))
        labelsContainer.addSubview(listenerImage)
        
        timeImage = UIImageView(image: UIImage(named: "time"))
        labelsContainer.addSubview(timeImage)
    }

    
    override func updateConstraints() {
        
        statusImage.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.left.equalTo(10)
            make.centerY.equalToSuperview().offset(-3)
        }

        statusLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(14)
            make.width.equalTo(60)
            make.left.equalTo(statusImage.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        /**  */
        listenerImage.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.centerX.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        listenerLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(14)
            make.width.equalTo(60)
            make.left.equalTo(listenerImage.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        /**  */
        
        timeImage.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.right.equalTo(timeLabel.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(14)
            make.left.equalTo(timeImage.snp.right).offset(-8)
            make.right.equalTo(superview!.frame.width).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        super.updateConstraints()
    }
    
    func update() {
        
        let resource = ImageResource(downloadURL: URL(string: (course?.image)!)!, cacheKey: (course?.image)!)
        courseImageView.kf.setImage(with: resource, placeholder: UIImage(named: "rect_placeholder"))
        courseImageView.layer.cornerRadius = 5
        courseImageView.clipsToBounds = true
        
        
        if course?.status == "" {
            course?.status = "未开始"
        }
        statusLabel.text = course?.status
        
        listenerLabel.text = "\((course?.listenCount)!)人在线"
        listenerLabel.sizeToFit()
        if course?.liveTime == "" {
            course?.liveTime = "时间未定"
        }
        timeLabel.text = course?.liveTime
        
    }

}
