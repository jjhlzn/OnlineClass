//
//  AudioPlayerExtension.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/16.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation

extension AudioPlayer {
    var isPlaying : Bool {
        get {
           return state == AudioPlayerState.Playing || state == AudioPlayerState.Buffering || state == AudioPlayerState.WaitingForConnection
        }
    }
}