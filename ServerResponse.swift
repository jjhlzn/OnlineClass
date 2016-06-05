//
//  ServerResponse.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation

enum ServerResponseStatus : Int {
    case Success = 0
}

class ServerRequest {
    var params: [String: AnyObject] {
        get {
            return [String: AnyObject]()
        }
    }
}

class PagedServerRequest: ServerRequest{
    var pageNo = 0
    var pageSize = 15
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["pageno"] = pageNo
            parameters["pagesize"] = pageSize
            return parameters
        }
    }
}


public class ServerResponse  {
    var status : Int = 0
    var errorMessage : String?
    required public init() {}
    func parseJSON(request: ServerRequest, json: NSDictionary) {
        status = json["status"] as! Int
        errorMessage = json["errorMessage"] as? String
    }
}

public class PageServerResponse<T> : ServerResponse{
    var totalNumber : Int = 0
    var resultSet: [T] = [T]()
    public required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
        if status == 0 {
            totalNumber = json["totalNumber"] as! Int
        }
    }
    
}


class GetAlbumsRequest : PagedServerRequest {
    var courseType : CourseType
    
    required init(courseType: CourseType) {
        self.courseType = courseType
    }
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            switch courseType {
            case .Common:
                parameters = ["type": "common"]
                break
            case .Live:
                parameters = ["type": "live"]
                break
            case .Vip:
                parameters = ["type": "vip"]
                break
                
            }
            return parameters

        }
    }
    
    
}



class GetAlbumsResponse : PageServerResponse<Album> {
    required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary)  {
        super.parseJSON(request, json: json)
        let jsonArray = json["albums"] as! NSArray
        var albums = [Album]()
        
        for albumJson in jsonArray {
            let album = Album()
            album.id = "\(albumJson["id"] as! NSNumber)"
            album.name = albumJson["name"] as! String
            album.author = albumJson["author"] as! String
            album.image = albumJson["image"] as! String
            album.courseType = CourseType(rawValue: albumJson["type"] as! String)!
            albums.append(album)
        }
        self.resultSet = albums
    }
}

class GetAlbumSongsRequest : ServerRequest {
    var album : Album
    init(album: Album) {
        self.album = album
    }
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["album"] = ["id": album.id]
            return parameters
            
        }
    }

    
}

class GetAlbumSongsResponse : ServerResponse {
    var resultSet: [Song] = [Song]()
    required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
        let req = request as! GetAlbumSongsRequest
        let jsonArray = json["songs"] as! NSArray
        var songs = [Song]()
        
        for json in jsonArray {
            var song : Song!
            let album = req.album
            if album.courseType == CourseType.Live {
                let liveSong = LiveSong()
                liveSong.imageUrl = json["image"] as? String
                liveSong.startDateTime = json["startTime"] as? String
                liveSong.endDateTime = json["endTime"] as? String
                song = liveSong
            } else {
                song = Song()
            }
            song.album = album
            song.name = json["name"] as! String
            song.desc = json["desc"] as! String
            song.date = json["date"] as! String
            song.url = json["url"] as! String
            song.id = json["id"] as! String
            let settings = SongSetting()
            song.settings = settings
            let settingsJson = json["settings"] as! NSDictionary
            settings.canComment = settingsJson["canComment"] as! Bool
            settings.maxCommentWord = settingsJson["maxCommentWord"] as! Int
            
            songs.append(song)
            
        }
        (request as! GetAlbumSongsRequest).album.songs = songs
        resultSet = songs
    }
}

class GetSongLiveCommentsRequest : ServerRequest {
    var song: Song
    var lastId: String
    init(song: Song, lastId: String) {
        self.song = song
        self.lastId = lastId
    }
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["song"] = ["id": song.id]
            parameters["lastId"] = lastId
            return parameters
        }
    }
}

class GetSongLiveCommentsResponse : ServerResponse {
    var comments = [Comment]()
    required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
        
        let jsonArray = json["comments"] as! NSArray
        comments = [Comment]()
        
        for json in jsonArray {
            let comment = Comment()
            comment.id = "\(json["id"] as? Int)"
            comment.song = (request as! GetSongLiveCommentsRequest).song
            comment.userId = json["userId"] as! String
            comment.time = json["time"] as! String
            comment.content = json["content"] as! String
            comments.append(comment)
        }
    }
}


class GetSongCommentsRequest : PagedServerRequest {
    var song: Song
    init(song: Song) {
        self.song = song
    }
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["song"] = ["id": song.id]
            return parameters
        }
    }

}

class GetSongCommentsResponse : PageServerResponse<Comment> {
    required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
        let jsonArray = json["comments"] as! NSArray
        var comments = [Comment]()
        
        for json in jsonArray {
            let comment = Comment()
            comment.id = "\(json["id"] as? Int)"
            comment.song = (request as! GetSongCommentsRequest).song
            comment.userId = json["userId"] as! String
            comment.time = json["time"] as! String
            comment.content = json["content"] as! String
            comments.append(comment)
        }
        resultSet = comments
    }
}


class SendCommentRequest : ServerRequest {
    var song: Song!
    var comment: String!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["song"] = ["id": song.id]
            parameters["comment"] = comment
            return parameters
        }
    }
}

class SendCommentResponse : ServerResponse {
    
}

class LoginRequest : ServerRequest {
    var userName : String 
    var password : String
    
    init(userName : String, password: String) {
        self.userName = userName
        self.password = password
    }
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["userName"] = userName
            parameters["password"] = password
            return parameters
        }
    }
}

class LoginResponse : ServerResponse {
    var name : String?
    var token : String?
    
    required init() {
        
    }
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)

        if status == 0 {
            name = json["name"] as? String
            token = json["token"] as? String
        }
    }

}

class GetPhoneCheckCodeRequest : ServerRequest {
    var phoneNumber : String
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["phoneNumber"] = phoneNumber
            return parameters
        }
    }

}

class GetPhoneCheckCodeResponse : ServerResponse {
    
}

class SignupRequest : ServerRequest {
    
    var phoneNumber : String
    var checkCode : String
    var invitePhone : String
    var password : String
    
    init(phoneNumber: String, checkCode: String, invitePhone: String, password: String) {
        self.phoneNumber = phoneNumber
        self.checkCode = checkCode
        self.invitePhone = invitePhone
        self.password = password
    }
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["phoneNumber"] = phoneNumber
            parameters["checkCode"] = checkCode
            parameters["invitePhone"] = invitePhone
            parameters["password"] = password
            return parameters
        }
    }
}

class SignupResponse : ServerResponse {
    
}

class GetPasswordRequest : ServerRequest {
    var phoneNumber : String
    var checkCode : String
    var password : String
    
    init(phoneNumber: String, checkCode: String, password: String) {
        self.phoneNumber = phoneNumber
        self.checkCode = checkCode
        self.password = password
    }
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["phoneNumber"] = phoneNumber
            parameters["checkCode"] = checkCode
            parameters["password"] = password
            return parameters
        }
    }
}

class GetPasswordResponse : ServerResponse {

}

class GetLiveListernerCountRequest : ServerRequest {
    var song: Song!
    init(song: Song) {
        self.song = song
    }
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["song"] = ["id": song.id]
            return parameters
        }
    }
}

class GetLiveListernerCountResponse : ServerResponse {
    var count = 0
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
        if status == 0 {
            count = json["count"] as! Int
        }
    }
}

class ResetPasswordRequest : ServerRequest {
    var oldPassword: String!
    var newPassword: String!
    
    required init(oldPassword: String, newPassword: String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
    }
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["oldPassword"] = oldPassword
            parameters["newPassword"] = newPassword
            return parameters
        }
    }
}

class ResetPasswordResponse : ServerResponse {
    
}


//获取邀请的人数
class GetClientNumberRequest : ServerRequest {
    
}

class GetClientNumberResponse : ServerResponse {
    var peopleCount = 0
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
        if status == 0 {
            peopleCount = json["peopleCount"] as! Int
        }
    }

    
}

class SearchRequest : PagedServerRequest {
    var keyword = ""
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["keyword"] = keyword
            return parameters
        }
    }
}

class SearchResponse : GetAlbumsResponse {
    
}