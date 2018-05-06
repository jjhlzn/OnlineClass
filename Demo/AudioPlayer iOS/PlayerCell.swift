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
        playerViewController?.loadArtImage()
        
        //setup progressbar
        var sliderImage = UIImage(named: "sliderImage")!
        sliderImage = sliderImage.scaledToSize(size: CGSize(width: 14, height: 14))
        progressBar.setThumbImage(sliderImage, for: [])
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0.0)
        let transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        //progressBar.setMinimumTrackImage(transparentImage, forState: .Normal)
        progressBar.setMaximumTrackImage(transparentImage, for: [])
        progressBar.isContinuous = true
        progressBar.addTarget(self, action: #selector(progressBarValueChanged), for: .valueChanged)
        progressBar.addTarget(self, action: #selector(progressBarTouchUp), for: .touchUpInside)
        progressBar.addTarget(self, action: #selector(progressBarTouchUp), for: .touchUpOutside)
        progressBar.addTarget(self, action: #selector(progressBarTouchDown), for: .touchDown)
        //progressBar.enabled = false
        
        //hidden bufferCircle
        bufferCircle.isHidden = true
        
        if !inited {
            bufferProgress.layer.transform = CATransform3DScale(bufferProgress.layer.transform, 1.0, 2.0, 1.5)
        }
        
        if audioPlayer.currentItemDuration != nil {
            durationLabel.text = Utils.stringFromTimeInterval(interval: audioPlayer.currentItemDuration!)
        }
        
        //update image
        
        if !isLive {
            if audioPlayer.state == AudioPlayerState.playing || audioPlayer.state == AudioPlayerState.paused || audioPlayer.state == AudioPlayerState.buffering {
                if audioPlayer.currentItem != nil && audioPlayer.currentItem?.artworkImage != nil {
                    artImageView!.image = audioPlayer.currentItem?.artworkImage!
                }
            }
        }
        
        //update progress bar
        playerViewController.updatePlayingProgress()
        
        inited = true
        
        //update button status
        playerViewController.updatePrevAndNextButtonStatus()
        playerViewController.updatePlayAndPauseButton()
        playerViewController.updateBufferProgress()
        playerViewController.updateBufferCircle()
        
        if songListImage != nil {
            let songListTap = UITapGestureRecognizer(target: self, action: #selector(songListButtonPressed))
            self.songListImage.addGestureRecognizer(songListTap)
            self.songListImage.isUserInteractionEnabled = true
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
        playButton.setImage(UIImage(named: "pause"), for: [])
        setMusicDefaultImage()
        controller?.playerPageViewController.reload()
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        handleNextSong()
    }
    
    func handleNextSong() {
        audioPlayer.next()
        playerViewController.resetButtonAndProgress()
        playButton.setImage(UIImage(named: "pause"), for: [])
        setMusicDefaultImage()
        controller?.playerPageViewController.reload()
    }
    
    private func setMusicDefaultImage() {

        
        let song = (audioPlayer.currentItem as! MyAudioItem).song
        if (song?.isLive)! {
            artImageView.image = UIImage(named: "liveMusicCover")
        } else {
            artImageView.image = UIImage(named: "musicCover")
        }
        
    }
    
    
    
    @IBAction func songListButtonPressed(sender: UIButton) {
        //显示歌单列表
        controller?.showSongList()
    }

    
    @objc func progressBarValueChanged() {
        if audioPlayer.currentItemDuration != nil {
            playingLabel.text = Utils.stringFromTimeInterval(interval: (audioPlayer.currentItemDuration)! * Double(progressBar.value))
        }
    }

    @objc func progressBarTouchUp() {
        
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
        playingLabel.text = Utils.stringFromTimeInterval(interval: newProgress)
        
        audioPlayer.seek(to: newProgress)

        updateProgressBar = true
    }
    
    @objc func progressBarTouchDown() {
        updateProgressBar = false
        startDragProgress = progressBar.value
    }
    


   

}
