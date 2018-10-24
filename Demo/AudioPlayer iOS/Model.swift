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

class CourseType: BaseModelObject {
    //case Common, Vip, Live
    static let LiveCourse = CourseType(name: "直播课程", code: "Live")
    static let PayCourse = CourseType(name: "会员专享课程", code: "Vip")
    var name : String
    var code : String
    init(name: String, code: String) {
        self.name = name
        self.code = code
    }
    
    var isLive : Bool {
        return true
    }
    
    static func getCourseType(code: String) -> CourseType? {
        if code ==  LiveCourse.code {
            return LiveCourse
        } else if code == PayCourse.code {
            return PayCourse
        }
        return nil
    }
}


class Album : BaseModelObject {
    var id: String = ""
    var name: String = ""
    var desc: String = ""
    var author: String = ""
    var image: String = ""
    var count: Int = 0
    var listenCount : String = ""
    var courseType = CourseType.LiveCourse
    var playing : Bool = false
    var isReady : Bool = false
    var isAgent: Bool = false
    var playTimeDesc: String = ""
    
    var date: String = ""
    var status: String = ""
    var stars: Double = 5
    var liveTime: String = ""
    var listenerCount: Int = 0
    
    var songs = [Song]()
    
    var hasImage: Bool {
        get {
            return !image.isEmpty
        }
    }
    
    var hasPlayTimeDesc: Bool {
        get {
            return !playTimeDesc.isEmpty
        }
    }
    
    override var description: String {
        get {
            return "{'id': \(id)}"
        }
    }
    
    var isLive: Bool {
        return courseType.isLive
    }
}

class SongSetting : BaseModelObject {
    var maxCommentWord: Int = 30
    var canComment: Bool = true
}

class Advertise : BaseModelObject {
    static let WEB = "web"
    static let COURSE = "course"
    
    var type = WEB
    var id = ""
    var imageUrl = ""
    var clickUrl = ""
    var title = ""
}

class Toutiao : BaseModelObject {
    var content = ""
    var clickUrl = ""
    var title = ""
}

class SearchResult : BaseModelObject{
    var title = ""
    var content = ""
    var clickUrl = ""
    var image = ""
    var date = ""
    var author = ""
    var desc = ""
}


 class Course : BaseModelObject {
    
    var id = "";
    var sequence : Int = 0;
    var title = "";
    var time = "";
    var introduction = "";
    var url = "";
    var beforeCourses = [Course]()
}

class Song : BaseModelObject {
    var id: String = ""
    var name: String = ""
    var desc: String = ""
    var date: String = ""
    var url: String = ""
    var imageUrl: String = ""
    var shareTitle: String = ""
    var shareUrl : String = ""
    var settings = SongSetting()
    var album: Album!
    var wholeUrl : String {
        return ServiceConfiguration.GetSongUrl(urlSuffix: url)
    }
    var isLive : Bool {
        return album.isLive
    }

    override var description: String {
        get {
            return "{'id': \(id)}"
        }
    }
    
}

class LiveSong : Song {
    let dateFormatter = DateFormatter()
    let dateFormatter2 = DateFormatter()
    override init() {
        super.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter2.dateFormat = "yyyy-MM-dd"
    }
    
    var startDateTime: String?
    var listenPeople: String = ""
    var introduction: String = ""
    
    
    var startTime: String? {
        get {
            if startDateTime == nil {
                return ""
            }
            return (startDateTime! as NSString).substring(from: 10)
        }
    }
    var endDateTime: String?
    var endTime: String? {
        get {
            if startDateTime == nil {
                return ""
            }
            return (endDateTime! as NSString).substring(from: 10)
        }
    }
    
    var totalTime: TimeInterval {
        //TODO:
        return TimeInterval(0)
        
        /*
        if startDateTime == nil || endDateTime == nil {
            return TimeInterval(0)
        }
        return dateFormatter.dateFromString(endDateTime!)!.timeIntervalSinceDate(dateFormatter.dateFromString(startDateTime!)!)
        */
 }
    
    var leftTime : TimeInterval {
        get {
            if startDateTime == nil || endDateTime == nil {
                return TimeInterval(0)
            }
            return dateFormatter.date(from: endDateTime!)!.timeIntervalSinceNow
        }
    }
    
    var playedTime : TimeInterval {
        get {
            if startDateTime == nil || endDateTime == nil {
                return TimeInterval(0)
            }
            return totalTime - leftTime

        }
    }
    
    var progress : Float {
        get {
            return Float( (self.totalTime - self.leftTime) / self.totalTime )
        }
    }
    
    var hasAdvImage : Bool!
    var advImageUrl: String?
    var advUrl: String?
    var advScrollRate = 5
    var scrollAds = [Advertise]()
    
    var advText = ""
    
}

class Comment : BaseModelObject {
    var id: String?
    var song: Song?
    var userId: String!
    var nickName: String!
    var time: String!
    var content: String!
    var isManager = false
    
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

class ZhuanLan : BaseModelObject {
    
    var name: String = ""
    var latest: String = ""
    var updateTime : String = ""
    var priceInfo : String = ""
    var desc: String = ""
    var imageUrl : String = ""
    var url : String = ""
    var author : String = ""
    var authorTitle : String = ""
    var dingyue : Int = 0
}

class ServiceLocator {
    var http: String!
    var serverName: String!
    var port: Int!
    var isUseServiceLocator: String!
    
    init() {
        
    }
    
    var needServieLocator : Bool {
        get {
            if isUseServiceLocator == nil {
                return true
            }
            
            return "1" == isUseServiceLocator
        }
    }

    
}

class PurchaseRecord {
    var userid: String! //mobile
    var productId: String!
    var isNotify: Bool = false
    var payTime: String!
}

class Question : BaseModelObject {
    var id : String!
    var userId : String!
    var userName : String!
    var content : String!
    var time : String!
    var isLiked : Bool!
    var answerCount: Int!
    var thumbCount : Int!
    var answers = [Answer]()
}

class Answer : BaseModelObject {
    var question : Question?
    var fromUserId : String!
    var fromUserName : String!
    var toUserId : String?
    var toUserName : String?
    var content : String!
    var isFromManager : Bool!
}

class FinanceToutiao : BaseModelObject {
    var title : String!
    var content : String!
    var link : String!
    var index : Int!
}

class Pos : BaseModelObject {
    var imageUrl : String!
    var clickUrl : String!
    var title : String!
}

class Message : BaseModelObject {
    var title: String!
    var desc : String!
    var time : String!
    var clickTitle : String!
    var clickUrl : String!
    
    var height: CGFloat! = 0
}
