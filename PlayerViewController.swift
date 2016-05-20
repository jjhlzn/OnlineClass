//
//  PlayerViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/16.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import KDEAudioPlayer
import UIKit

class PlayerViewController : NSObject, AudioPlayerDelegate {
    
    var cell : PlayerCell!
    var audioPlayer : AudioPlayer!
    
    init(playerCell : PlayerCell) {
        self.cell = playerCell
    }
    
    func initPlayerController() {
        audioPlayer = Utils.getAudioPlayer()
        audioPlayer.delegate = self
    }
    
    func playOrPause() {
        if audioPlayer.state == AudioPlayerState.Playing || audioPlayer.state == AudioPlayerState.Buffering ||
           audioPlayer.state == AudioPlayerState.WaitingForConnection {
            audioPlayer.pause()
        } else {
            audioPlayer.resume()
        }

    }
    
    func resetButtonAndProgress () {
        cell.playingLabel.text = "00:00"
        cell.durationLabel.text = "00:00"
        cell.bufferProgress.progress = 0
        cell.progressBar.value = 0
        cell.progressBar.enabled = false
        cell.playButton.setImage(UIImage(named: "play"), forState: .Normal)
    }
    
    
    func updatePrevAndNextButtonStatus() {
        if audioPlayer.hasNext() {
            cell.nextButton.enabled = true
        } else {
            cell.nextButton.enabled = false
        }
        
        if audioPlayer.hasPrevious() {
            cell.preButton.enabled = true
            
        } else {
            cell.preButton.enabled = false
        }
    }
    
    func updatePlayAndPauseButton() {
        if audioPlayer.state == AudioPlayerState.Playing || audioPlayer.state == AudioPlayerState.WaitingForConnection || audioPlayer.state == AudioPlayerState.Buffering  {
            cell.playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        } else {
            cell.playButton.setImage(UIImage(named: "play"), forState: .Normal)
        }
        
    }
    
    func updatePlayingProgress() {
        
        if cell.updateProgressBar && audioPlayer.currentItemProgression != nil && audioPlayer.currentItemDuration != nil{
            let progress = Float(audioPlayer.currentItemProgression! / audioPlayer.currentItemDuration!)
            if cell.oldProgress != nil {
                if cell.isForward {
                    if progress > cell.oldProgress! {
                        //print("current = \(audioPlayer.currentItemDuration!), oldProgress = \(oldProgress!)")
                        cell.progressBar.value = progress
                        cell.playingLabel.text = Utils.stringFromTimeInterval(audioPlayer.currentItemProgression!)
                        cell.oldProgress = nil
                    }
                } else {
                    if progress < cell.oldProgress! {
                        //print("current = \(audioPlayer.currentItemDuration!), oldProgress = \(oldProgress!)")
                        cell.progressBar.value = progress
                        cell.playingLabel.text = Utils.stringFromTimeInterval(audioPlayer.currentItemProgression!)
                        cell.oldProgress = nil
                    }
                }
                
            } else {
                cell.progressBar.value = progress
                cell.playingLabel.text = Utils.stringFromTimeInterval(audioPlayer.currentItemProgression!)
            }
        }
        
    }
    
    
    func updateBufferProgress() {
        if audioPlayer.currentItemDuration != nil && audioPlayer.currentItemLoadedRange != nil {
            cell.bufferProgress.progress = Float( audioPlayer.currentItemLoadedRange!.latest / audioPlayer.currentItemDuration!)
            cell.progressBar.enabled = true
            
        } else {
            cell.bufferProgress.progress = 0
        }
    }
    
    let kRotationAnimationKey = "com.myapplication.rotationanimationkey" // Any key
    
    func rotateView(view: UIView, duration: Double = 1) {
        if view.layer.animationForKey(kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float(M_PI * 2.0)
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity
            
            view.layer.addAnimation(rotationAnimation, forKey: kRotationAnimationKey)
        }
    }
    
    func updateBufferCircle() {
        let state = audioPlayer.state
        if state == AudioPlayerState.Buffering || state == AudioPlayerState.WaitingForConnection {

            cell.bufferCircle.hidden = false
            rotateView(cell.bufferCircle, duration: 1.3)

        } else {
            cell.bufferCircle.hidden = true
            
        }
    }

    
    /*  AudioPlayerDelegate Implement functions   */
    func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        print("audioPlayer:didChangeStateFrom called，from = \(from), to = \(to)")
        updatePrevAndNextButtonStatus()
        updatePlayAndPauseButton()
        
        
        if to == AudioPlayerState.Stopped || to == AudioPlayerState.WaitingForConnection {
            cell.progressBar.enabled = false
        }
        
        if to == AudioPlayerState.Buffering || to == AudioPlayerState.Playing {
            cell.progressBar.enabled = true
        }
        
        updateBufferCircle()
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        print("audioPlayer:willStartPlayingItem called")
        cell.artImageView.image = item.artworkImage
        cell.controller?.title = (item as! MyAudioItem).song?.name
    }
    
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float) {
        //print("audioPlayer:didUpdateProgressionToTime called, progressPercentage = \(percentageRead)");
        //print("audioPlayer:didUpdateProgressionToTime called")
        updatePlayingProgress()
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem) {
        print("duration = \(duration)")
        cell.durationLabel.text = Utils.stringFromTimeInterval(duration)
    }
    
    
    func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        print("audioPlayer:didLoadRange, loadRange = \(range)")
        updateBufferProgress()
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        print("audioPlayer:didUpdateEmptyMetadataOnItem called")
        if audioPlayer.currentItem != nil && audioPlayer.currentItem?.artworkImage != nil {
            cell.artImageView.image = audioPlayer.currentItem?.artworkImage!
        }
    }

}




