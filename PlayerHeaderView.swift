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
    
    private func getAduioPlayer() -> AudioPlayer {
        return Utils.getAudioPlayer()
    }
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var playerBtn: UIImageView!
    @IBOutlet weak var listenerCountLabel: UILabel!
    @IBOutlet weak var playerStatusLabel: UILabel!
    @IBOutlet weak var listenerImage: UIImageView!
    
    @IBOutlet var container: UIView!
    
    func initalize() {
        let audioPlayer = getAduioPlayer()
        if audioPlayer.currentItem != nil {
            update()
        }
        playerBtn.isUserInteractionEnabled = true
        let tap  = UITapGestureRecognizer(target: self, action: #selector(tapMusic))
        playerBtn.addGestureRecognizer(tap)
        listenerCountLabel.text = "0人"
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
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(height + PlayerHeaderView.interHeight)
        }
        
        playerStatusLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.width.equalTo(100)
            make.left.equalTo(playerBtn.snp.right).offset(10)
            make.centerY.equalTo(playerBtn)
        }
        
        listenerCountLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.left.equalTo(listenerImage.snp.right).offset(10)
            make.right.equalToSuperview().offset(-30)
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
        let audioPlayer = getAduioPlayer()
        let item = audioPlayer.currentItem as! MyAudioItem
        if item != nil {
            if let song = Utils.getPlayingSong() as? LiveSong {
                songImageView.kf.setImage(with: URL(string: song.imageUrl), placeholder: UIImage(named: "rect_placeholder"))
                listenerCountLabel.text = song.listenPeople
                listenerCountLabel.textColor = UIColor.red
                listenerCountLabel.sizeToFit()
                
                updateMusicButton()
            }
        }
    }
    
    var lastStateBeforePause : AudioPlayerState?
    @objc func tapMusic(sender: UITapGestureRecognizer) {
         let audioPlayer = getAduioPlayer()
        let state = audioPlayer.state
        
        //QL1("currentState = \(state)")
        //QL1("lastStateBeforePause = \(lastStateBeforePause)")
        
        switch state {
        case AudioPlayerState.buffering,  AudioPlayerState.waitingForConnection:
            lastStateBeforePause = state
            audioPlayer.pause()
            break
        case AudioPlayerState.playing:
            lastStateBeforePause = state
            audioPlayer.pause()
            break
        case AudioPlayerState.failed( _):
            QL1("retry after failed")
            lastStateBeforePause = state
            audioPlayer.retryAnyway()
            break
        case AudioPlayerState.stopped:
            QL1("retry after stopped")
            audioPlayer.retryAnyway()
            break
        default:
            if lastStateBeforePause == AudioPlayerState.buffering {
                QL1("retry because of buffering paused")
                audioPlayer.retryAnyway()
            } else {
                audioPlayer.seekToSeekableRangeEnd(padding: 1, completionHandler: nil)
                audioPlayer.resume()
            }
            
        }
        updateMusicButton()
        
        
    }
    
    func updateMusicButton() {
        let audioPlayer = getAduioPlayer()
        let state : AudioPlayerState = audioPlayer.state
        //QL1("state = \(state)" )
        //QL1(audioPlayer)
        //QL1(audioPlayer.delegate)
        switch state {
        case AudioPlayerState.buffering, AudioPlayerState.waitingForConnection:
            playerBtn.image = UIImage(named: "playerButton2")
            playerStatusLabel.text = "缓冲中"
            audioPlayer.setError(false)
            break
        case AudioPlayerState.playing:
            playerBtn.image = UIImage(named: "playerButton2")
            playerStatusLabel.text = "播放中"
            audioPlayer.setError(false)
            break
        case AudioPlayerState.failed(let error):
            QL1("error happen")
            QL3(error)
            audioPlayer.setError(true)
            playerBtn.image = UIImage(named: "playerButton")
            playerStatusLabel.text = "直播未开始"
            break
        default:
            // access api value here
            playerBtn.image = UIImage(named: "playerButton")
            playerStatusLabel.text = "开始播放"
            audioPlayer.setError(false)
        }
    }
    
    func updateListenerCountLabel(_ count: Int) {
        listenerCountLabel.text = "\(count)人在线"
        listenerCountLabel.sizeToFit()
    }

}
