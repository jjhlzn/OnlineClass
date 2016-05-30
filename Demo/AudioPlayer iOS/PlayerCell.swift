 //
//  PlayerCell.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/21.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer

class PlayerCell: UITableViewCell {
    var controller: SongViewController?
    
    var audioPlayer: AudioPlayer!
    @IBOutlet weak var artImageView: UIImageView!
    
    @IBOutlet weak var bufferProgress: UIProgressView!
    
    @IBOutlet weak var progressBar: UISlider!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playingLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var preButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var bufferCircle: UIImageView!
    
    @IBOutlet weak var songListButton: UIButton!
    @IBOutlet weak var songListImage: UIImageView!
    
    var inited = false
    var updateProgressBar: Bool = true
    var isForward = true
    var oldProgress: Float?
    var startDragProgress: Float?
    var playerViewController: PlayerViewController!
    
    func initPalyer() {
        audioPlayer = Utils.getAudioPlayer()
        
        var  isLive = false
       
        if let liveSong = (audioPlayer.currentItem as! MyAudioItem).song as? LiveSong {
            playerViewController = LivePlayerViewController(playerCell: self)
            isLive = true
            
        } else {
            playerViewController = PlayerViewController(playerCell: self)
        }
        
        playerViewController.initPlayerController()
        
        audioPlayer.delegate = playerViewController
        
        //setup progressbar
        progressBar.setThumbImage(UIImage(named: "sliderImage"), forState: .Normal)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0.0)
        let transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        //progressBar.setMinimumTrackImage(transparentImage, forState: .Normal)
        progressBar.setMaximumTrackImage(transparentImage, forState: .Normal)
        progressBar.continuous = true
        progressBar.addTarget(self, action: #selector(progressBarValueChanged), forControlEvents: .ValueChanged)
        progressBar.addTarget(self, action: #selector(progressBarTouchUp), forControlEvents: .TouchUpInside)
        progressBar.addTarget(self, action: #selector(progressBarTouchUp), forControlEvents: .TouchUpOutside)
        progressBar.addTarget(self, action: #selector(progressBarTouchDown), forControlEvents: .TouchDown)
        progressBar.enabled = false
        
        //hidden bufferCircle
        bufferCircle.hidden = true
        
        if !inited {
            bufferProgress.layer.transform = CATransform3DScale(bufferProgress.layer.transform, 1.0, 2.0, 1.5)
        }
        
        if audioPlayer.currentItemDuration != nil {
            durationLabel.text = Utils.stringFromTimeInterval(audioPlayer.currentItemDuration!)
        }
        
        //update image
        if !isLive {
            if audioPlayer.state == AudioPlayerState.Playing || audioPlayer.state == AudioPlayerState.Paused || audioPlayer.state == AudioPlayerState.Buffering {
                if audioPlayer.currentItem != nil && audioPlayer.currentItem?.artworkImage != nil {
                    artImageView!.image = audioPlayer.currentItem?.artworkImage!
                }
            }
        }
        
        //update progress bar
        if audioPlayer.currentItemProgression != nil && audioPlayer.currentItemDuration != nil {
            progressBar.value = Float(audioPlayer.currentItemProgression! / audioPlayer.currentItemDuration!)
            playingLabel.text = Utils.stringFromTimeInterval(audioPlayer.currentItemProgression!)
        }
        
        inited = true
        
        //update button status
        playerViewController.updatePrevAndNextButtonStatus()
        playerViewController.updatePlayAndPauseButton()
        playerViewController.updateBufferProgress()
        playerViewController.updateBufferCircle()
        
        if songListImage != nil {
            let songListTap = UITapGestureRecognizer(target: self, action: #selector(songListButtonPressed))
            self.songListImage.addGestureRecognizer(songListTap)
            self.songListImage.userInteractionEnabled = true
        }
    }
    
    /*      Event Handler       */
    @IBAction func playButtonPressed(sender: UIButton) {
        playerViewController.playOrPause()
    }
    
    @IBAction func prevButtonPressed(sender: UIButton) {
        handlePrevSong()
    }
    
    
    
    func handlePrevSong() {
        audioPlayer.previous()
        playerViewController.resetButtonAndProgress()
        playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        artImageView.image = UIImage(named: "musicCover")
        controller?.playerPageViewController.reload()
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        handleNextSong()
    }
    
    func handleNextSong() {
        audioPlayer.next()
        playerViewController.resetButtonAndProgress()
        playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        artImageView.image = UIImage(named: "musicCover")
        controller?.playerPageViewController.reload()
    }
    
    
    
    @IBAction func songListButtonPressed(sender: UIButton) {
        //显示歌单列表
        controller?.showSongList()
    }

    
    func progressBarValueChanged() {
        if audioPlayer.currentItemDuration != nil {
            playingLabel.text = Utils.stringFromTimeInterval((audioPlayer.currentItemDuration)! * Double(progressBar.value))
        }
    }

    func progressBarTouchUp() {
        
        if audioPlayer.currentItemDuration == nil {
            return
        }
        
        let newProgress = (audioPlayer.currentItemDuration)! * Double(progressBar.value)
        isForward = newProgress > audioPlayer.currentItemProgression!
        if isForward {
            oldProgress = progressBar.value
        } else {
            oldProgress = startDragProgress
        }
        playingLabel.text = Utils.stringFromTimeInterval(newProgress)
        
        audioPlayer.seekToTime(newProgress)

        updateProgressBar = true
    }
    
    func progressBarTouchDown() {
        updateProgressBar = false
        startDragProgress = progressBar.value
    }
    


   

}
