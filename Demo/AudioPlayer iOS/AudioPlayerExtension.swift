//
//  AudioPlayerExtension.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/16.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation

extension AudioPlayer {
    
    
    func playThisSong(song: Song) {
        let album = song.album
        var items = [AudioItem]()
        var idx = 0
        var startIndex = 0
        for eachSong in album.songs {
            if eachSong.wholeUrl == song.wholeUrl {
                startIndex = idx
            }
            let audioItem = AudioItem(highQualitySoundURL: NSURL(string: eachSong.wholeUrl))!
            audioItem.song = eachSong
            print(audioItem.song?.name)
            items.append(audioItem)
            
            idx = idx + 1
        }
        playItems(items, startAtIndex: startIndex)
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
    
    public func hasPrevious() -> Bool {
        if currentItemIndexInQueue == nil {
            return false
        }
        
        return currentItemIndexInQueue! != 0
        
    }
    
}

class MyAudioItem : AudioItem {
    /*
    var song: Song!
    
    convenience init?(song: Song, highQualitySoundURL: NSURL? = nil, mediumQualitySoundURL: NSURL? = nil, lowQualitySoundURL: NSURL? = nil) {
        var URLs = [AudioQuality: NSURL]()
        if let highURL = highQualitySoundURL {
            URLs[.High] = highURL
        }
        if let mediumURL = mediumQualitySoundURL {
            URLs[.Medium] = mediumURL
        }
        if let lowURL = lowQualitySoundURL {
            URLs[.Low] = lowURL
        }
        self.init(song: song, soundURLs: URLs)
    }
    
    
    init?(song: Song, soundURLs: [AudioQuality: NSURL]) {
        super.init(soundURLs: soundURLs)
        self.song = song
    } */

}