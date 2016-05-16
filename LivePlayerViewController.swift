//
//  LivePlayerViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/16.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import KDEAudioPlayer


class LivePlayerViewController : PlayerViewController {
    
    override func initPlayerController() {
        super.initPlayerController()
        //- 获取直播的图片
        //- 直播隐藏进度条和缓冲条
        //- 直播就没有上一首和上一首

        cell.progressBar.hidden = true
        cell.preButton.enabled = false
        cell.nextButton.enabled = false
        cell.playingLabel.hidden = true
        cell.durationLabel.hidden = true
        
        let song = (audioPlayer.currentItem as! MyAudioItem).song as! LiveSong
        
        cell.artImageView.downloadedFrom(link: song.imageUrl!, contentMode: .ScaleAspectFit)
    }
    
}
