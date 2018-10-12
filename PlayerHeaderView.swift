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
import SnapKit

class PlayerHeaderView: BaseCustomView {

    var audioPlayer : AudioPlayer?
    
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var playerBtn: UIImageView!
    @IBOutlet weak var listenerCountLabel: UILabel!
    @IBOutlet weak var playerStatusLabel: UILabel!
    @IBOutlet weak var listenerImage: UIImageView!
    
    @IBOutlet var container: UIView!
    
    /*
    
    @IBOutlet weak var playerBtn: UIImageView!
    
    @IBOutlet weak var container: UIView!
    
    var songImageView: UIImageView!
    //var playerBtn: UIButton!
    var listenerImage : UIImageView!
    var listenerCountLabel: UILabel!
    var playerStatusLabel: UILabel! */
    
    override func initialSetup(){
       //makeViews()
    }
    
    func initalize() {
        if audioPlayer?.currentItem != nil {
            update()
        }
        playerBtn.isUserInteractionEnabled = true
        let tap  = UITapGestureRecognizer(target: self, action: #selector(tapMusic))
        playerBtn.addGestureRecognizer(tap)
        
    }
    
    
    
    
    static let  interHeight : CGFloat = 15
    static func getHeight() -> CGFloat {
        let sceenWidth = UIScreen.main.bounds.width
        let height = sceenWidth / 375 * 177
        return height + interHeight * 2 + 20
    }
    
    override func updateConstraints() {
        let sceenWidth = UIScreen.main.bounds.width
        container.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(PlayerHeaderView.getHeight())
            make.width.equalTo(sceenWidth)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        

        let height = sceenWidth / 375 * 177
        songImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(sceenWidth )
            make.height.equalTo(sceenWidth / 375 * 177)
            make.left.equalTo(0)
            make.top.equalTo(0)
        }
        
        playerBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.left.equalTo(container).offset(30)
            make.top.equalTo(container).offset(height + PlayerHeaderView.interHeight)
        }
        
        playerStatusLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.width.equalTo(100)
            make.left.equalTo(playerBtn.snp.right).offset(10)
            make.centerY.equalTo(playerBtn)
        }
        
        listenerCountLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.left.equalTo(listenerImage.snp.right).offset(30)
            make.right.equalTo(container.snp.right).offset(-30)
            make.centerY.equalTo(playerBtn)
        }
        
        listenerImage.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.right.equalTo(listenerCountLabel.snp.left).offset(-10)
            make.centerY.equalTo(playerBtn)
        }
        
        super.updateConstraints()
    }
    
    
    func update() {
        let item = audioPlayer?.currentItem as! MyAudioItem
        let song = item.song as! LiveSong
        songImageView.kf.setImage(with: URL(string: song.imageUrl), placeholder: UIImage(named: "rect_placeholder"))
        listenerCountLabel.text = song.listenPeople
        listenerCountLabel.textColor = UIColor.red
        listenerCountLabel.sizeToFit()
        
        updateMusicButton()
       // updateConstraints()
        
     
    }
    
    @objc func tapMusic(sender: UITapGestureRecognizer) {
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
        //QL1("state = \(state!)" )
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
    
    func updateListenerCountLabel(_ count: Int) {
        listenerCountLabel.text = "\(count)人在线"
        listenerCountLabel.sizeToFit()
    }

}
