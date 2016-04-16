//
//  SongViewController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class SongViewController: UIViewController, AudioPlayerDelegate {

    var song: Song!
    var audioPlayer: AudioPlayer!
    var paused: Bool = false
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var progressBar: UISlider!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var preButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        audioPlayer = AudioPlayer()
        audioPlayer.delegate = self
        
        let album = song.album
        var audioItems = [AudioItem]()
        var startIndex = 0
        var index = 0
        for item in album.songs {
            let url = NSURL(string: ServiceConfiguration.GetSongUrl(item.url))
            let audioItem = AudioItem(highQualitySoundURL: url)
            audioItems.append(audioItem!)
            if item.url == song.url {
                startIndex = index
            }
            index = index + 1
        }
        
        audioPlayer.playItems(audioItems, startAtIndex: startIndex)
        if !audioPlayer.hasNext() {
            nextButton.enabled = false
        }
        playButton.setImage(UIImage(named: "pause"), forState: .Normal)
    }
    
    
    @IBAction func playButtonPressed(sender: UIButton) {
        if !paused {
            audioPlayer.pause()
            //sender.setTitle("播放", forState: .Normal)
            sender.setImage(UIImage(named: "play"), forState: .Normal)
        }else {
            
            audioPlayer.resume()
            sender.setImage(UIImage(named: "pause"), forState: .Normal)
        }
        paused = !paused
    }
    
    
    @IBAction func prevButtonPressed(sender: UIButton) {
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
    }
    
    
    func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float) {
        print("audioPlayer didUpdateProgressionToTime called \(percentageRead)");
        progressBar.value = percentageRead / 100
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem) {
        print("duration = \(duration)")
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        print("data = \(data)")
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        print("range = \(range)")
    }

    @IBAction func progressChanged(sender: UISlider) {
        audioPlayer.seekToTime((audioPlayer.currentItemDuration)! * Double(sender.value))
    }
    
}
