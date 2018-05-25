//
//  PlayerHeaderView.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/13.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer
import QorumLogs

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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMusic))
        playerBtn.isUserInteractionEnabled = true
        playerBtn.addGestureRecognizer(tap)
        updateMusicButton()
    }
    
    @objc func tapMusic(_ sender: UITapGestureRecognizer) {
        QL1("tap music")
        let state = audioPlayer?.state
        if state == AudioPlayerState.buffering || state == AudioPlayerState.waitingForConnection {
            audioPlayer?.pause()
        } else if state == AudioPlayerState.playing {
            audioPlayer?.pause()
        } else {
             audioPlayer?.seekToSeekableRangeEnd(padding: 1, completionHandler: nil)
            audioPlayer?.resume()
        }
        updateMusicButton()
    }
    
    func updateMusicButton() {
        let state = audioPlayer?.state
        QL1("state = \(state!)" )
        if state == AudioPlayerState.buffering || state == AudioPlayerState.waitingForConnection {
            playerBtn.image = UIImage(named: "playerButton2")
            playerStatusLabel.text = "缓冲中"
        } else if state == AudioPlayerState.playing {
            playerBtn.image = UIImage(named: "playerButton2")
            playerStatusLabel.text = "播放中"
        } else {
            playerBtn.image = UIImage(named: "playerButton")
            playerStatusLabel.text = "开始播放"
        }
    }

}
