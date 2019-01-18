//
//  AudioPlayerExtension.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/16.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import KDEAudioPlayer
import QorumLogs

extension AudioPlayer {
    
    func retryIfHasError() {
        switch state {
        case AudioPlayerState.failed(_):
            retryAnyway()
            break
        default:
            break
        }
    }
    
    func retryAnyway() {
        
       
        if items != nil {
            let newItems = items!
            self.stop()
            
            self.play(items: newItems, startAtIndex: 0)
        }
    }
    
    func setError(_ hasError: Bool) {
        if currentItem == nil {
            return
        }
        
        if (currentItem as! MyAudioItem).song == nil {
            return
        }
        
        (currentItem as! MyAudioItem).hasError = hasError
    }
    
    func playThisSong(song: Song) {
        let album = song.album
        var items = [AudioItem]()
        var idx = 0
        var startIndex = 0
        for eachSong in (album?.songs)! {
            if eachSong.wholeUrl == song.wholeUrl {
                startIndex = idx
            }
            let url = URL(string: eachSong.wholeUrl)
            QL1(url)
            let  audioItem = MyAudioItem(song: eachSong, highQualitySoundURL: url)!
            audioItem.song = eachSong
            items.append(audioItem)
            
            idx = idx + 1
        }
        play(items: items, startAtIndex: startIndex)
    }
    
    func isPlayThisSong(song: Song) -> Bool {
        if currentItem == nil {
            return false
        }
        
        if (currentItem as! MyAudioItem).song.id == song.id {
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
    
    var song: Song!
    var hasError : Bool = false
    
    convenience init?(song: Song, highQualitySoundURL: URL? = nil, mediumQualitySoundURL: URL? = nil, lowQualitySoundURL: URL? = nil) {
        var URLs = [AudioQuality: URL]()
        if let highURL = highQualitySoundURL {
            URLs[.high] = highURL
        }
        if let mediumURL = mediumQualitySoundURL {
            URLs[.medium] = mediumURL
        }
        if let lowURL = lowQualitySoundURL {
            URLs[.low] = lowURL
        }
        self.init(song: song, soundURLs: URLs)
    }
    
    
    init?(song: Song, soundURLs: [AudioQuality: URL]) {
        super.init(soundURLs: soundURLs as [AudioQuality : URL])
        self.song = song
    }

}
