//
//  ViewController2.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/13.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController2: UIViewController, AudioPlayerDelegate {

    // MARK: Properties
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var loadProgressLabel: UILabel!
    
    @IBOutlet weak var progressSlide: UISlider!
    
    var isPause = false
    
    var sound1: AudioPlayer?

    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.progress = 0;
        progressLabel.text = "0%"

            
        sound1 = AudioPlayer()
        sound1?.delegate = self
        
        print("ViewController2")
    }
    
    // MARK: IBAction
    
    @IBAction func playSound1Pressed(sender: AnyObject) {
        /*
        do {
            var audioItem = try AudioItem(fileName: "test.mp3")
        
        let url = NSURL(string: "https://ia802205.us.archive.org/27/items/RepublicKnightIntroSamplemp3///RepublicKnightIntroSamplemp3_64kb.m3u")
            let url2 = NSURL(string: "https://dl.dropboxusercontent.com/u/995250/FreeStreamer/As%20long%20as%20the%20stars%20shine.mp3")
            
            let url3 = NSURL(string: "http://localhost:3000/test.mp3")
            let url4 = NSURL(string: "http://www.jinjunhang.com:3000/test.mp3")
            audioItem = AudioItem(highQualitySoundURL: url4)

            //print(audioItem?.highestQualityURL.URL.absoluteString)
        sound1?.playItem(audioItem!)
        } catch {
            print("playSound1Pressed failed")
        }*/
    }
    
    
    @IBAction func stopSound1Pressed(sender: AnyObject) {
        sound1?.stop()
    }
    
    @IBAction func sound1LoopPressed(sender: UISwitch) {
        //sound1?.numberOfLoops = sender.on ? -1 : 0
    }
    
    @IBAction func sound1VolumeValueDidChange(sender: UISlider) {
        //sound1?.volume = sender.value
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float) {
        print("audioPlayer didUpdateProgressionToTime called \(percentageRead)");
        progressLabel.text = "\(percentageRead)%"
        progressBar.progress = percentageRead / 100
        progressSlide.value = percentageRead / 100
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem) {
        print("duration = \(duration)")
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        print("data = \(data)")
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        print("range = \(range)")
        let duration = sound1?.currentItemDuration
        loadProgressLabel.text = "\(range.latest / duration! * 100)%"
    }
    
    @IBAction func middlePressed(sender: AnyObject) {
        sound1?.seekToTime((sound1?.currentItemDuration)! * 0.75)
    }

    @IBAction func pausePressed(sender: AnyObject) {
        if isPause {
            sound1?.resume()
            isPause = false
        } else {
            sound1?.pause()
            isPause = true
        }
        
        
    }
    @IBAction func slowPressed(sender: UIButton) {
        sound1?.rate = 0.5
    }
    
    
    @IBAction func normalPressed(sender: AnyObject) {
         sound1?.rate = 1
    }
    
    @IBAction func fastPressed(sender: UIButton) {
         sound1?.rate = 2
    }
    
    @IBAction func progressChanged(sender: UISlider) {
        let value = Double(progressSlide.value)
        sound1?.seekToTime((sound1?.currentItemDuration)! * Double(progressSlide.value))
    }
    
}
