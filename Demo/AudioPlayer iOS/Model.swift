//
//  Model.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation


class BaseModelObject : NSObject {
    
}


enum CourseType: String {
    case Common, Vip, Live
}

class Album : BaseModelObject {
    var id: String = ""
    var name: String = ""
    var author: String = ""
    var image: String = ""
    var courseType = CourseType.Common
    var songs = [Song]()
    
    var hasImage: Bool {
        get {
            return !image.isEmpty
        }
    }
    
    override var description: String {
        get {
            return "{'id': \(id)}"
        }
    }
}

class SongSetting : BaseModelObject {
    var maxCommentWord: Int = 30
    var canComment: Bool = true
}

class Song : BaseModelObject {
    var id: String = ""
    var name: String = ""
    var desc: String = ""
    var date: String = ""
    var url: String = ""
    var settings = SongSetting()
    var album: Album!
    var wholeUrl : String {
        return ServiceConfiguration.GetSongUrl(url)
    }
    override var description: String {
        get {
            return "{'id': \(id)}"
        }
    }
}

class LiveSong : Song {
    let dateFormatter = NSDateFormatter()
    let dateFormatter2 = NSDateFormatter()
    override init() {
        super.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter2.dateFormat = "yyyy-MM-dd"
    }
    
    var imageUrl: String?
    var startDateTime: String?
    var startTime: String? {
        get {
            if startDateTime == nil {
                return ""
            }
            return (startDateTime! as NSString).substringFromIndex(10)
        }
    }
    var endDateTime: String?
    var endTime: String? {
        get {
            if startDateTime == nil {
                return ""
            }
            return (endDateTime! as NSString).substringFromIndex(10)
        }
    }
    
    var totalTime: NSTimeInterval {
        if startDateTime == nil || endDateTime == nil {
            return NSTimeInterval(0)
        }
        return dateFormatter.dateFromString(endDateTime!)!.timeIntervalSinceDate(dateFormatter.dateFromString(startDateTime!)!)
    }
    
    var leftTime : NSTimeInterval {
        get {
            if startDateTime == nil || endDateTime == nil {
                return NSTimeInterval(0)
            }
            return dateFormatter.dateFromString(endDateTime!)!.timeIntervalSinceNow
        }
    }
    
    var progress : Float {
        get {
            return Float( (self.totalTime - self.leftTime) / self.totalTime )
        }
    }
}

class Comment : BaseModelObject {
    var id: String?
    var song: Song?
    var userId: String!
    var time: String!
    var content: String!
    
}

class User : BaseModelObject{
    var userName: String!
    var name: String = ""
    override var description: String {
        get {
            return "{'userName': \(userName)}"
        }
    }
}

class ChatSetting : BaseModelObject {
    var maxWordSize : Int = 50
    var canComment: Bool = true
    var lastCommenTime : NSDate?
    
}