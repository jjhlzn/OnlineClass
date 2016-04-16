//
//  SongViewController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import MediaPlayer

class SongViewController: BaseUIViewController, UIGestureRecognizerDelegate {

    //var song: Song!
    var audioPlayer: AudioPlayer!

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var progressBar: UISlider!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var preButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    var inited = false
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        audioPlayer = getAudioPlayer()
        //audioPlayer.delegate = self
        
        
        if !audioPlayer.hasNext() {
            nextButton.enabled = false
        }
        
        if audioPlayer.isPlaying {
            playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        }
        else {
            playButton.setImage(UIImage(named: "play"), forState: .Normal)

        }
        
        print("audioPlayer.sate ")
        if audioPlayer.isPlaying || audioPlayer.state == AudioPlayerState.Paused {
            print(audioPlayer.currentItemProgression)
            if audioPlayer.currentItemProgression != nil && audioPlayer.currentItemDuration != nil {
                
                progressBar.value = Float(audioPlayer.currentItemProgression! / audioPlayer.currentItemDuration!)
                print("set progress bar to \(progressBar.value)")
            }
        }
        
        inited = true
        
        updatePrevAndNextButtonStatus()
    }
    
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    
    @IBAction func playButtonPressed(sender: UIButton) {
        if audioPlayer.state == AudioPlayerState.Playing {
            audioPlayer.pause()
        } else {
            audioPlayer.resume()
        }
        
    
    }
    
    
    @IBAction func prevButtonPressed(sender: UIButton) {
        audioPlayer.previous()
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        audioPlayer.next()
    }
    
    func updatePrevAndNextButtonStatus() {
        if audioPlayer.hasNext() {
            nextButton.enabled = true
        } else {
            nextButton.enabled = false
        }
        
        if audioPlayer.hasPrevious() {
            preButton.enabled = true
            
        } else {
            preButton.enabled = false
        }
    }
    
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        if to == AudioPlayerState.Playing {
            playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        } else {
            playButton.setImage(UIImage(named: "play"), forState: .Normal)
        }
        updatePrevAndNextButtonStatus()
        
    }
    
    
    override func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float) {
        //print("audioPlayer didUpdateProgressionToTime called \(percentageRead)");
        progressBar.value = percentageRead / 100
        
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem) {
        print("duration = \(duration)")
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        print("data = \(data)")
        
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        print("range = \(range)")
    }

    @IBAction func progressChanged(sender: UISlider) {
        if !inited {
            return
        }
        audioPlayer.seekToTime((audioPlayer.currentItemDuration)! * Double(sender.value))
    }
    
}
