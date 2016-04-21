//
//  BaseUIViewController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/16.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class BaseUIViewController: UIViewController, AudioPlayerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAudioPlayer().delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        getAudioPlayer().delegate = nil
        
        if self.navigationController?.viewControllers.indexOf(self) == nil {
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
    


}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
