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
    
    
    override init(playerCell : PlayerCell) {
        super.init(playerCell: playerCell)
    }
    
    override func initPlayerController() {
        super.initPlayerController()
        
        //暂时认为一个直播album只有一个直播节目
        cell.preButton.enabled = false
        cell.nextButton.enabled = false
        cell.bufferProgress.progress = 0
        
        let song = (audioPlayer.currentItem as! MyAudioItem).song as! LiveSong
        //获取直播的时间
        cell.playingLabel.text = Utils.getCurrentTime()
        cell.durationLabel.text = song.endTime
        
        //- 获取直播的图片
        //cell.artImageView.downloadedFrom(link: song.imageUrl!, contentMode: .ScaleAspectFit)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.liveProgressTimer == nil {
            appDelegate.liveProgressTimer  = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(updatePlayingProgress), userInfo: nil, repeats: true)
        }
        
        cell.progressBar.value =  Float(song.leftTime / song.totalTime)
        
    
    }
    
    var stopItem: AudioItem?
    override func playOrPause() {
        if audioPlayer.state == AudioPlayerState.Playing {
            stopItem = audioPlayer.currentItem
            audioPlayer.stop()
            
        } else {
            audioPlayer.seekToSeekableRangeEnd(0)
            if stopItem != nil {
                audioPlayer.playItem(stopItem!)
            }
        }
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        print("LivePlayerViewController:didChangeStateFrom called，from = \(from), to = \(to)")
        updatePrevAndNextButtonStatus()
        updatePlayAndPauseButton()
        
        updateBufferCircle()

    }
    
    //加载直播信息，不能删除
    override func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        print("LivePlayerViewController:willStartPlayingItem called")
        
    }
    
    //更新播放进度条，不能删除
    override func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float){

    }
    
    //更新缓冲进度条，不能删除
    override func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        print("LivePlayerViewController:didLoadRange, loadRange = \(range)")
        updateBufferProgress()
    }
    
    //更新基础信息，不能删除
    override func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        
    }
    
    private func getCurrentSong() -> LiveSong {
        return (audioPlayer.currentItem as! MyAudioItem).song as! LiveSong
    }
    
    
    override func updateBufferProgress() {
        print("LivePlayerViewController:updateBufferProgress")
        let beforeTime = NSTimeInterval( getCurrentSong().totalTime - getCurrentSong().leftTime )
        if audioPlayer.currentItemLoadedRange != nil {
            cell.bufferProgress.progress = Float( (beforeTime + audioPlayer.currentItemLoadedRange!.latest) / NSTimeInterval( getCurrentSong().totalTime) )
        }

    }
    
    var isPlaying : Bool {
        get {
            return self.audioPlayer.state == AudioPlayerState.Playing
        }
    }
    
    override func updatePlayingProgress() {
        if isPlaying {
            //print("LivePlayerViewController:updatePlayingProgress")

            cell.playingLabel.text = Utils.getCurrentTime()
             cell.progressBar.value = getCurrentSong().progress
        }
        
    }


    
}
