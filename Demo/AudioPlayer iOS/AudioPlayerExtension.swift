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
    
    func playUsingUrl(url: String) {
        playItems([AudioItem(highQualitySoundURL: NSURL(string: url))!], startAtIndex: 0)
    }
    
    func isPlayThisSong(song: Song) -> Bool {
        if currentItem == nil {
            return false
        }
        
        if currentItem!.highestQualityURL.URL.absoluteString == song.wholeUrl {
            return true
        }
        
        return false
    }
}