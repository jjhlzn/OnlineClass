//
//  FirstPageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/23.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer

class FirstPageViewController: BaseUIViewController {
    
    @IBOutlet weak var getMoneyImage: UIButton!
    @IBOutlet weak var getMoneyLabel: UILabel!
    @IBOutlet weak var couseLabel: UILabel!
    @IBOutlet weak var couseImage: UIButton!

    @IBOutlet weak var playingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlayingButton(button: playingButton)
        getMoneyLabel.frame.origin.y = getMoneyImage.frame.origin.y + getMoneyImage.frame.size.height + 7
        couseLabel.frame.origin.y = couseImage.frame.origin.y + couseImage.frame.size.height + 7
        
        
        //收款添加Tap Gesture
        let getMoneyTap = UITapGestureRecognizer(target: self, action: #selector(tapGetMoneyImage))
        getMoneyImage.addGestureRecognizer(getMoneyTap)
        getMoneyImage.isUserInteractionEnabled = true
    }
    
    @objc func tapGetMoneyImage() {
        UIApplication.shared.openURL(NSURL(string: "itms://itunes.apple.com/")! as URL)
        
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        let audioItem = getAudioPlayer().currentItem
        if audioItem == nil {
            print("audioItem is nil")
            return
        }
        updatePlayingButton(button: playingButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePlayingButton(button: playingButton)
    }
    

}
