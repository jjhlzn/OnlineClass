//
//  ViewController2.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/13.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController2: BaseUIViewController {

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

            
        // sound1 = getAudioPlayer()
        sound1 = AudioPlayer()
        sound1?.delegate = self
        print("ViewController2")
    }
    
    // MARK: IBAction
    
    @IBAction func playSound1Pressed(sender: AnyObject) {
        

        
        let url = NSURL(string: "https://ia802205.us.archive.org/27/items/RepublicKnightIntroSamplemp3/RepublicKnightIntroSamplemp3_64kb.m3u")
            let url2 = NSURL(string: "https://dl.dropboxusercontent.com/u/995250/FreeStreamer/As%20long%20as%20the%20stars%20shine.mp3")
            
            let url3 = NSURL(string: "http://v38.yunpan.cn/Download.outputAudio/350592516/46a97077afac032f342e4468c4ad45503a067d7c/38_36.2dbe9ef90a758dd90cae6e83e211570e/1.0.1/web/14609040083236/0/52a7a7de7ea49d512c96d765dc6097ee/Kalimba.mp3")
            let url4 = NSURL(string: "http://jjhaudio.hengdianworld.com/songs/houlai.mp3")
        let audioItem = AudioItem(highQualitySoundURL: url3)

            //print(audioItem?.highestQualityURL.URL.absoluteString)
        sound1?.playItem(audioItem!)
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
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float) {
        print("audioPlayer didUpdateProgressionToTime called \(percentageRead)");
        progressLabel.text = "\(percentageRead)%"
        progressBar.progress = percentageRead / 100
        progressSlide.value = percentageRead / 100
        
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem) {
        print("duration = \(duration)")
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        print("data = \(data)")
        
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        print("range = \(range)")
        let duration = sound1?.currentItemDuration
        if duration != nil {
            loadProgressLabel.text = "\(range.latest / duration! * 100)%"
        }
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
