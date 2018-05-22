//
//  PlayerHeaderView.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/13.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer

class PlayerHeaderView: BaseCustomView {

    var audioPlayer : AudioPlayer?
    @IBOutlet weak var songImageView: UIImageView!
    
    @IBOutlet weak var playerBtn: UIImageView!
    
    @IBOutlet weak var listenerCountLabel: UILabel!
    @IBOutlet weak var playerStatusLabel: UILabel!

    
    func initalize() {
        let item = audioPlayer?.currentItem as! MyAudioItem
        let song = item.song as! LiveSong
        songImageView.kf.setImage(with: URL(string: song.imageUrl))
        listenerCountLabel.text = song.listenPeople
    }

}
