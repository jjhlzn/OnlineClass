//
//  BaseUIViewController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/16.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer

class BaseUIViewController: UIViewController, AudioPlayerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAudioPlayer().delegate = self
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    }
    
    
    
    func isNeedResetAudioPlayerDelegate() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        getAudioPlayer().delegate = nil
        
        if isNeedResetAudioPlayerDelegate() && self.navigationController?.viewControllers.indexOf(self) == nil {
            getAudioPlayer().delegate = (self.parentViewController as! UINavigationController).topViewController as! AudioPlayerDelegate
            
        }

    }
    
    
    func getAudioPlayer() -> AudioPlayer {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.audioPlayer
    }
    
    func addPlayingButton(button: UIButton) {
        button.addTarget(self, action: #selector(playingButtonPressed), forControlEvents: .TouchUpInside)
    }
    
    func playingButtonPressed(sender: UIButton) {
        if hasCurrentItem() {
            performSegueWithIdentifier("songSegue", sender: false)
        }
    }
    
    func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
    }
    
    private func hasCurrentItem() -> Bool {
        return getAudioPlayer().currentItem != nil
    }
    
    func updatePlayingButton(button: UIButton) {
        let audioPlayer = getAudioPlayer()
        print("audioPlayer.state = \(audioPlayer.state)")
        if audioPlayer.state == AudioPlayerState.Playing || audioPlayer.state == AudioPlayerState.Buffering
            || audioPlayer.state == AudioPlayerState.WaitingForConnection{
            
            let image = UIImage.animatedImageWithImages([UIImage(named: "wave1")!, UIImage(named: "wave2")!], duration: NSTimeInterval(0.8))
            button.setImage(image, forState: .Normal)
        } else {
            button.setImage(UIImage(named: "wave1"), forState: .Normal)
        }
    }

    func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        print("audioPlayer:didChangeStateFrom called")
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        print("audioPlayer:willStartPlayingItem called")
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float) {
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem) {

    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        print("audioPlayer:didUpdateEmptyMetadataOnItem called, metaData = \(data)")
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){

    }
    
    func becomeLineBorder(field: UITextField) {
        field.borderStyle = .None
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, field.frame.size.height - 1, field.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        field.layer.addSublayer(bottomBorder)
    }
    
    func setTextFieldHeight(field: UITextField, height: CGFloat) {
        var frameRect = field.frame
        frameRect.size.height = height
        field.frame = frameRect
    }

   
    var tap: UITapGestureRecognizer!
}

extension BaseUIViewController {
    func displayMessage(message : String) {
        
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButtonWithTitle("好的")
        alertView.cancelButtonIndex=0
        alertView.delegate=self
        alertView.show()
        
    }
    
    func hideKeyboardWhenTappedAround() {
        
        view.addGestureRecognizer(tap)
    }
    
    func cancleHideKeybaordWhenTappedAround() {
        view.removeGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }


}
