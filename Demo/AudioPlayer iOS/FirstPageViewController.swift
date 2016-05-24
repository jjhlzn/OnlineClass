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
    

    @IBOutlet weak var playingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlayingButton(playingButton)
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        let audioItem = getAudioPlayer().currentItem
        if audioItem == nil {
            print("audioItem is nil")
            return
        }
        updatePlayingButton(playingButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePlayingButton(playingButton)
    }
    

}
