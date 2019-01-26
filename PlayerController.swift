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
import QorumLogs

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
        if audioPlayer.state == AudioPlayerState.playing || audioPlayer.state == AudioPlayerState.buffering ||
            audioPlayer.state == AudioPlayerState.waitingForConnection {
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
        cell.progressBar.isEnabled = false
        cell.playButton.setImage(UIImage(named: "play"), for: [])
    }
    
    
    func updatePrevAndNextButtonStatus() {
        if audioPlayer.hasNext {
            cell.nextButton.isEnabled = true
        } else {
            cell.nextButton.isEnabled = false
        }
        
        if audioPlayer.hasPrevious() {
            cell.preButton.isEnabled = true
            
        } else {
            cell.preButton.isEnabled = false
        }
    }
    
    func updatePlayAndPauseButton() {
        if audioPlayer.state == AudioPlayerState.playing || audioPlayer.state == AudioPlayerState.waitingForConnection || audioPlayer.state == AudioPlayerState.buffering  {
            cell.playButton.setImage(UIImage(named: "pause"), for: [])
        } else {
            cell.playButton.setImage(UIImage(named: "play"), for: [])
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
                        cell.playingLabel.text = Utils.stringFromTimeInterval(interval: audioPlayer.currentItemProgression!)
                        cell.oldProgress = nil
                    }
                } else {
                    if progress < cell.oldProgress! {
                        //print("current = \(audioPlayer.currentItemDuration!), oldProgress = \(oldProgress!)")
                        cell.progressBar.value = progress
                        cell.playingLabel.text = Utils.stringFromTimeInterval(interval: audioPlayer.currentItemProgression!)
                        cell.oldProgress = nil
                    }
                }
                
            } else {
                cell.progressBar.value = progress
                cell.playingLabel.text = Utils.stringFromTimeInterval(interval: audioPlayer.currentItemProgression!)
            }
        }
        
    }
    
    
    func updateBufferProgress() {
        if audioPlayer.currentItemDuration != nil && audioPlayer.currentItemLoadedRange != nil {
            cell.bufferProgress.progress = Float( audioPlayer.currentItemLoadedRange!.latest / audioPlayer.currentItemDuration!)
            cell.progressBar.isEnabled = true
            
        } else {
            cell.bufferProgress.progress = 0
        }
    }
    
    let kRotationAnimationKey = "com.myapplication.rotationanimationkey" // Any key
    
    func rotateView(view: UIView, duration: Double = 1) {
        if view.layer.animation(forKey: kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float(Double.pi * 2.0)
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity
            
            view.layer.add(rotationAnimation, forKey: kRotationAnimationKey)
        }
    }
    
    func updateBufferCircle() {
        let state = audioPlayer.state
        QL1("updateBufferCircle: state = \(state)" )
        if state == AudioPlayerState.buffering || state == AudioPlayerState.waitingForConnection {

            cell.bufferCircle.isHidden = false
            rotateView(view: cell.bufferCircle, duration: 1.3)

        } else {
            cell.bufferCircle.isHidden = true
            
        }
    }

    
    /*  AudioPlayerDelegate Implement functions   */
    func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        print("audioPlayer:didChangeStateFrom called，from = \(from), to = \(to)")
        updatePrevAndNextButtonStatus()
        updatePlayAndPauseButton()
        
        
        if to == AudioPlayerState.stopped || to == AudioPlayerState.waitingForConnection {
            cell.progressBar.isEnabled = false
        }
        
        if to == AudioPlayerState.buffering || to == AudioPlayerState.playing {
            cell.progressBar.isEnabled = true
        }
        
        updateBufferCircle()
        
    }
    
    func loadArtImage() {
         /*
        let item = audioPlayer.currentItem
        if item != nil {
            let song = (item as! MyAudioItem).song
            cell.controller?.title = song.name
            cell.artImageView.kf_setImageWithURL(NSURL(string: song.imageUrl)!, placeholderImage: UIImage(named: getPlaceHolderMusicImageName()))
        }
        */
    }
    
    func getPlaceHolderMusicImageName() -> String {
        return "musicCover"
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        print("audioPlayer:willStartPlayingItem called")
        //cell.artImageView.image = item.artworkImage
        loadArtImage()

    }
    
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: TimeInterval, percentageRead: Float) {
        //print("audioPlayer:didUpdateProgressionToTime called, progressPercentage = \(percentageRead)");
        //print("audioPlayer:didUpdateProgressionToTime called")
        updatePlayingProgress()
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: TimeInterval, forItem item: AudioItem) {
        print("duration = \(duration)")
        cell.durationLabel.text = Utils.stringFromTimeInterval(interval: duration)
    }
    
    /*
    func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        print("audioPlayer:didLoadRange, loadRange = \(range)")
        updateBufferProgress()
    }*/
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        print("audioPlayer:didUpdateEmptyMetadataOnItem called")
    }

}




