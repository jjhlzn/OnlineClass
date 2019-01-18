//
//  LearnFinanceCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/11/27.
//  Copyright © 2018 tbaranes. All rights reserved.
//

import UIKit

class LearnFinanceCell: UITableViewCell {
    
    @IBOutlet weak var tagImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    var learnFinanceItem : LearnFinanceItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update() {
        let audioPlayer = Utils.getAudioPlayer()
        let song = Song()
        song.id = learnFinanceItem!.songId
        contentLabel.text = learnFinanceItem!.title
        if audioPlayer.isPlayThisSong(song: song)
            && (audioPlayer.state == .buffering || audioPlayer.state == .playing) {
            contentLabel.textColor = Utils.hexStringToUIColor(hex: "FD7510")
            tagImage.image = UIImage(named: "learn_finance_playing")
        } else {
            contentLabel.textColor = UIColor.black
            tagImage.image = UIImage(named: "toutiao_placeholder")
        }
        
    }
    
}

