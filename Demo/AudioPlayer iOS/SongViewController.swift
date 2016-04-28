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
    
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomView: UIView!
     var keyboardHeight: CGFloat?

    

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var bufferProgress: UIProgressView!
    
    @IBOutlet weak var progressBar: UISlider!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playingLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var preButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    var inited = false
    var updateProgressBar: Bool = true
    var isForward = true
    var oldProgress: Float?
    var startDragProgress: Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        

        
        bottomView2.hidden = true
        commentFiled2.editable = true
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        audioPlayer = getAudioPlayer()

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
        
        
        if audioPlayer.currentItemDuration != nil {
            durationLabel.text = stringFromTimeInterval(audioPlayer.currentItemDuration!)
        }
        
        //update image
        if audioPlayer.state == AudioPlayerState.Playing || audioPlayer.state == AudioPlayerState.Paused || audioPlayer.state == AudioPlayerState.Buffering {
            if audioPlayer.currentItem != nil && audioPlayer.currentItem?.artworkImage != nil {
                imageView!.image = audioPlayer.currentItem?.artworkImage!
            }
        }
        
        //update progress bar
        if audioPlayer.currentItemProgression != nil && audioPlayer.currentItemDuration != nil {
            progressBar.value = Float(audioPlayer.currentItemProgression! / audioPlayer.currentItemDuration!)
            playingLabel.text = stringFromTimeInterval(audioPlayer.currentItemProgression!)
        }
        
        inited = true
        
        //update button status
        updatePrevAndNextButtonStatus()
        updatePlayAndPauseButton()
        updateBufferProgress()
        

    }
    
    func resetButtonAndProgress () {
        playingLabel.text = "00:00"
        durationLabel.text = "00:00"
        bufferProgress.progress = 0
        progressBar.value = 0
        playButton.setImage(UIImage(named: "play"), forState: .Normal)
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
    
    func updatePlayAndPauseButton() {
        if audioPlayer.state == AudioPlayerState.Playing || audioPlayer.state == AudioPlayerState.Buffering || AudioPlayerState.WaitingForConnection == audioPlayer.state  {
            playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        } else {
            playButton.setImage(UIImage(named: "play"), forState: .Normal)
        }

    }
    
    func updatePlayingProgress() {
        
        if updateProgressBar && audioPlayer.currentItemProgression != nil && audioPlayer.currentItemDuration != nil{
            let progress = Float(audioPlayer.currentItemProgression! / audioPlayer.currentItemDuration!)
            if oldProgress != nil {
                if isForward {
                    if progress > oldProgress! {
                        //print("current = \(audioPlayer.currentItemDuration!), oldProgress = \(oldProgress!)")
                        progressBar.value = progress
                        playingLabel.text = stringFromTimeInterval(audioPlayer.currentItemProgression!)
                        oldProgress = nil
                    }
                } else {
                    if progress < oldProgress! {
                        //print("current = \(audioPlayer.currentItemDuration!), oldProgress = \(oldProgress!)")
                        progressBar.value = progress
                        playingLabel.text = stringFromTimeInterval(audioPlayer.currentItemProgression!)
                        oldProgress = nil
                    }
                }
                
            } else {
                progressBar.value = progress
                playingLabel.text = stringFromTimeInterval(audioPlayer.currentItemProgression!)
            }
        }
    }
    
    func updateBufferProgress() {
        if audioPlayer.currentItemDuration != nil && audioPlayer.currentItemLoadedRange != nil {
            bufferProgress.progress = Float( audioPlayer.currentItemLoadedRange!.latest / audioPlayer.currentItemDuration!)
        } else {
            bufferProgress.progress = 0
        }
    }
    
    /*      Event Handler       */
    @IBAction func playButtonPressed(sender: UIButton) {
        if audioPlayer.state == AudioPlayerState.Playing {
            audioPlayer.pause()
        } else {
            audioPlayer.resume()
        }
    }
    
    @IBAction func prevButtonPressed(sender: UIButton) {
        audioPlayer.previous()
        resetButtonAndProgress()
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        audioPlayer.next()
        resetButtonAndProgress()
    }
    
    func progressBarValueChanged() {
        playingLabel.text = stringFromTimeInterval((audioPlayer.currentItemDuration)! * Double(progressBar.value))
    }
    
    
    @IBAction func sendComment(sender: AnyObject) {
    }
    
    @IBAction func closeComment(sender: AnyObject) {
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
        playingLabel.text = stringFromTimeInterval(newProgress)
        audioPlayer.seekToTime(newProgress)
        //print("seekToTime")
        updateProgressBar = true
        //print("setupdateProgressBar to true")
    }
    
    func progressBarTouchDown() {
        updateProgressBar = false
        startDragProgress = progressBar.value
    }
    
    
    /*  AudioPlayerDelegate Implement functions   */
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        
        updatePrevAndNextButtonStatus()
        updatePlayAndPauseButton()
        
    }
    
    
    override func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float) {
        //print("audioPlayer:didUpdateProgressionToTime called, progressPercentage = \(percentageRead)");
        updatePlayingProgress()
        
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem) {
        print("duration = \(duration)")
        durationLabel.text = stringFromTimeInterval(duration)
    }

    
    override func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        //print("audioPlayer:didLoadRange, loadRange = \(range)")
        updateBufferProgress()
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        if audioPlayer.currentItem != nil && audioPlayer.currentItem?.artworkImage != nil {
            imageView!.image = audioPlayer.currentItem?.artworkImage!
        }
    }

    /* UIGestureRecognizerDelegate functions   */
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    var comments: [Comment]?
}


extension SongViewController {
    


   
    func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        
        commentFiled2.becomeFirstResponder()
        //showOverlay()
        bottomView2.hidden = false
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            //print("keyboardSize = \(keyboardSize.height)")
            if keyboardHeight != nil {
                self.view.frame.origin.y += (keyboardHeight! - keyboardSize.height)
                //print("diff = \(keyboardHeight! - keyboardSize.height)")
            } else {
                self.view.frame.origin.y -= keyboardSize.height
            }
            keyboardHeight = keyboardSize.height
        }
    }
    
    
    
    func keyboardWillHide(notification: NSNotification) {
        
        keyboardHeight = nil
        bottomView2.hidden = true
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
        //hideOverlay()
    }

}


