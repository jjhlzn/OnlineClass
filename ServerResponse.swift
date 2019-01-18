//
//  ServerResponse.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import SwiftyJSON
import QorumLogs

enum ServerResponseStatus : Int {
    case Success = 0
    case NoEnoughAuthority = -10  //没有足够的权限
    case TokenInvalid = -11 //token无效，或过期
}

class ServerRequest {
    var test: String = ""  //用了测试token失效
    var params: [String: AnyObject] {
        get {
            var parameters = [String: AnyObject]()
            parameters["test"] = test as AnyObject
            return parameters
        }
    }
    
    private func addMoreRequestInfo(params: [String: AnyObject]?) -> [String: AnyObject] {
        var newParams = [String: AnyObject]()
        newParams["request"] = params as AnyObject
        newParams["client"] = getClientInfo() as AnyObject
        newParams["userInfo"] = getUserInfo() as AnyObject
        return newParams
        
    }
    
    func getJSON() -> JSON {
        let finalParams = addMoreRequestInfo(params: params)
        return JSON(finalParams)
    }
    
    private func getClientInfo() -> [String: AnyObject]{
        var clientInfo = [String: AnyObject]()
        clientInfo["platform"] = "iphone" as AnyObject
        clientInfo["model"] = UIDevice.current.model as AnyObject
        clientInfo["osversion"] = UIDevice.current.systemVersion as AnyObject
        
        let screensize = UIScreen.main.bounds
        clientInfo["screensize"] = "\(screensize.width)*\(screensize.height)" as AnyObject
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let appBundle = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        clientInfo["appversion"] = "\(version).\(appBundle)" as AnyObject
        return clientInfo
        
    }
    
    
    private func getUserInfo() -> [String: AnyObject] {
        let loginUserStore = LoginUserStore()
        var userInfo = [String: AnyObject]()
        let loginUser = loginUserStore.getLoginUser()
        userInfo["userid"] = loginUser?.userName! as AnyObject
        userInfo["token"] = loginUser?.token! as AnyObject
        return userInfo
    }

}

class PagedServerRequest: ServerRequest{
    var pageNo = 0
    var pageSize = 15
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["pageno"] = pageNo as AnyObject
            parameters["pagesize"] = pageSize as AnyObject
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
    var isSuccess:Bool {
        get {
            return status == ServerResponseStatus.Success.rawValue
        }
    }
    
    var isFail:Bool {
        get {
            return !isSuccess
        }
    }
}

public class PageServerResponse<T> : ServerResponse{
    var totalNumber : Int = 0
    var resultSet: [T] = [T]()
    public required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        if status == 0 {
            totalNumber = json["totalNumber"] as! Int
        }
    }
    
}

class GetAlbumsRequest : PagedServerRequest {
    var code : String
    
    required init(courseType: CourseType) {
        self.code = courseType.code
    }
    
    required init(code: String) {
        self.code = code
    }
    
    override var params: [String : AnyObject] {
        get {
            let parameters = ["type": self.code]
            return parameters as [String : AnyObject]
        }
    }
}


class GetAlbumsResponse : PageServerResponse<Album> {
    required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary)  {
        super.parseJSON(request: request, json: json)
        let jsonArray = json["albums"] as! NSArray
        var albums = [Album]()
        
        for albumJson1 in jsonArray {
            let albumJson = albumJson1 as! [String:AnyObject]
            let album = Album()
            album.id = "\(albumJson["id"] as! NSNumber)"
            album.name = albumJson["name"] as! String
            album.author = albumJson["author"] as! String
            album.image = albumJson["image"] as! String
            album.count = albumJson["count"] as! Int
            album.desc = albumJson["desc"] as! String
            album.listenCount = albumJson["listenCount"] as! String
            album.courseType = CourseType.getCourseType(code: albumJson["type"] as! String)!
            album.playing = albumJson["playing"] as! Bool
            album.isReady = albumJson["isReady"] as! Bool
            
            if let playTimeDesc = albumJson["playTimeDesc"] {
                album.playTimeDesc = playTimeDesc != nil ? playTimeDesc as! String : ""
            }
            if let isAgent = albumJson["isAgent"] {
                album.isAgent = isAgent != nil ? isAgent as! Bool : false
            }
            albums.append(album)
        }
        self.resultSet = albums
    }
}

class GetAlbumSongsRequest : PagedServerRequest {
    var album : Album
    init(album: Album) {
        self.album = album
    }
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            var a = [String:Any]()
            a["id"] = album.id as AnyObject
            parameters["album"] = a as AnyObject
            return parameters
            
        }
    }

    
}

class GetAlbumSongsResponse : ServerResponse {
    var resultSet: [Song] = [Song]()
    required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let req = request as! GetAlbumSongsRequest
        let jsonArray = json["songs"] as! NSArray
        var songs = [Song]()
        
        for json1 in jsonArray {
            let json = json1 as! [String: AnyObject]
            var song : Song!
            let album = req.album
            if album.isLive {
                let liveSong = LiveSong()
                liveSong.startDateTime = json["startTime"] as? String
                liveSong.endDateTime = json["endTime"] as? String
                liveSong.listenPeople = json["listenPeople"] as! String
                liveSong.hasAdvImage = json["hasAdvImage"] as! Bool
                if liveSong.hasAdvImage! {
                    liveSong.advImageUrl = json["advImageUrl"] as? String
                    liveSong.advUrl = json["advUrl"] as? String
                }
                
                if json["advUrl"] != nil {
                    liveSong.advUrl = json["advUrl"] as? String
                }
                
                liveSong.advScrollRate = json["advScrollRate"] as! Int
                liveSong.advText = json["advText"] as! String
                let adImages = json["advImages"] as! NSArray
                for adImageJson1 in adImages {
                    let adImageJson = adImageJson1 as! [String: AnyObject]
                    let adImage = Advertise()
                    adImage.imageUrl = adImageJson["imageurl"] as! String
                    adImage.clickUrl = adImageJson["link"] as! String
                    adImage.title = adImageJson["title"] as! String
                    liveSong.scrollAds.append(adImage)
                }
                liveSong.introduction = json["introduction"] as! String
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
            song.imageUrl = json["image"] as! String
            song.shareTitle = json["shareTitle"] as! String
            song.shareUrl = json["shareUrl"] as! String
            
            
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
            var a = [String:AnyObject]()
            a["id"] = song.id as AnyObject
            parameters["song"] = a as AnyObject
            parameters["lastId"] = lastId as AnyObject
            return parameters
        }
    }
}

class GetSongLiveCommentsResponse : ServerResponse {
    var comments = [Comment]()
    required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        
        let jsonArray = json["comments"] as! NSArray
        comments = [Comment]()
        
        for eachJSON1 in jsonArray {
            let eachJSON = eachJSON1 as! [String:AnyObject]
            let comment = Comment()
            comment.id = "\(eachJSON["id"] as! Int)"
            comment.song = (request as! GetSongLiveCommentsRequest).song
            comment.userId = eachJSON["userId"] as! String
            comment.time = eachJSON["time"] as! String
            comment.content = eachJSON["content"] as! String
            comment.nickName = eachJSON["name"] as! String
            comment.isManager = eachJSON["isManager"] as! Bool
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
            var a = [String:AnyObject]()
            a["id"] = song.id as AnyObject
            parameters["song"] = a as AnyObject
            return parameters
        }
    }

}

class GetSongCommentsResponse : PageServerResponse<Comment> {
    required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let jsonArray = json["comments"] as! NSArray
        var comments = [Comment]()
        
        for json1 in jsonArray {
            let json = json1 as! [String:AnyObject]
            let comment = Comment()
            comment.id = "\(json["id"] as? Int)"
            comment.song = (request as! GetSongCommentsRequest).song
            comment.userId = json["userId"] as! String
            comment.nickName = json["name"] as! String
            comment.time = json["time"] as! String
            comment.content = json["content"] as! String
            comments.append(comment)
        }
        resultSet = comments
    }
}

func makeDict(key key: String, value value: AnyObject) -> AnyObject {
    var a = [String:AnyObject]()
    a[key] = value
    return a as AnyObject
}

class SendCommentRequest : ServerRequest {
    var song: Song!
    var comment: String!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["song"] = makeDict(key: "id", value: song.id as AnyObject)
            parameters["comment"] = comment as AnyObject
            return parameters
        }
    }
}

class SendCommentResponse : ServerResponse {

}

class SendLiveCommentRequest : ServerRequest {
    var song: Song!
    var lastId: String!
    var comment: String!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["song"] = makeDict(key: "id", value: song.id as AnyObject)
            parameters["lastId"] = lastId as AnyObject
            parameters["comment"] = comment as AnyObject
            return parameters
        }
    }
}

class SendLiveCommentResponse : ServerResponse {
    var comments = [Comment]()
    required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        
        let jsonArray = json["comments"] as! NSArray
        comments = [Comment]()
        
        for eachJSON1 in jsonArray {
            let eachJSON = eachJSON1 as! [String:AnyObject]
            let comment = Comment()
            comment.id = "\(eachJSON["id"] as! Int)"
            comment.song = (request as! SendLiveCommentRequest).song
            comment.userId = eachJSON["userId"] as! String
            comment.nickName = eachJSON["name"] as! String
            comment.time = eachJSON["time"] as! String
            comment.content = eachJSON["content"] as! String
            comments.append(comment)
        }
    }

}

class LoginRequest : ServerRequest {
    var userName : String 
    var password : String
    var deviceToken : String
    
    init(userName : String, password: String, deviceToken: String) {
        self.userName = userName
        self.password = password
        self.deviceToken = deviceToken
    }
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["userName"] = userName as AnyObject
            parameters["password"] = password as AnyObject
            parameters["deviceToken"] = deviceToken as AnyObject
            return parameters
        }
    }
}

class LoginResponse : ServerResponse {
    var name : String?
    var token : String?
    var nickName: String!
    var level: String!
    var boss: String?
    var sex: String = ""
    var codeImageUrl: String = ""
    var userId : String!
    
    required init() {
        
    }
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        if status == 0 {
            userId = j["userid"].stringValue
            name = j["name"].stringValue
            token = j["token"].stringValue
            sex = j["sex"].stringValue
            
            codeImageUrl = j["codeImageUrl"].stringValue
            nickName = j["nickname"].stringValue
            level = j["level"].stringValue
            boss = j["boss"].stringValue
        }
    }

}

class MobileLoginRequest : ServerRequest {
    var userName : String
    var checkCode : String
    var deviceToken : String
    
    init(userName : String, checkCode : String, deviceToken: String) {
        self.userName = userName
        self.checkCode = checkCode
        self.deviceToken = deviceToken
    }
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["mobile"] = userName as AnyObject
            parameters["checkCode"] = checkCode as AnyObject
            parameters["deviceToken"] = deviceToken as AnyObject
            return parameters
        }
    }
}

class MobileLoginResponse : LoginResponse {}

class UpdateTokenRequest : ServerRequest {
    var userName : String
    var password : String
    
    init(userName : String, password: String) {
        self.userName = userName
        self.password = password
    }
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["userName"] = userName as AnyObject
            parameters["password"] = password as AnyObject
            return parameters
        }
    }
}

class UpdateTokenResponse : ServerResponse {
    var name : String?
    var token : String?
    var sex: String = ""
    var codeImageUrl: String = ""
    
    required init() {
        
    }
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        
        if status == 0 {
            name = json["name"] as? String
            token = json["token"] as? String
            sex = json["sex"] as! String
            codeImageUrl = json["codeImageUrl"] as! String
        }
    }
}

class LogoutRequest : ServerRequest {
    
}

class LogoutResponse : ServerResponse {
    
}

class GetPhoneCheckCodeRequest : ServerRequest {
    var phoneNumber : String
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["phoneNumber"] = phoneNumber as AnyObject
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
            parameters["phoneNumber"] = phoneNumber as AnyObject
            parameters["checkCode"] = checkCode as AnyObject
            parameters["invitePhone"] = invitePhone as AnyObject
            parameters["password"] = password as AnyObject
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
            parameters["phoneNumber"] = phoneNumber as AnyObject
            parameters["checkCode"] = checkCode as AnyObject
            parameters["password"] = password as AnyObject
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
            parameters["song"] = makeDict(key: "id", value: song.id as AnyObject)
            return parameters
        }
    }
}

class GetLiveListernerCountResponse : ServerResponse {
    var count = 0
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        if status == 0 {
            count = json["listerCount"] as! Int
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
            parameters["oldPassword"] = oldPassword as AnyObject
            parameters["newPassword"] = newPassword as AnyObject
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
        super.parseJSON(request: request, json: json)
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
            parameters["keyword"] = keyword as AnyObject
            return parameters
        }
    }
}

class SearchResponse : GetAlbumsResponse {
    
}

class GetHotSearchWordsRequest : ServerRequest {
    
}

class GetHotSearchWordsResponse : ServerResponse {
    var keywords = [String]()
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        if status == 0 {
            keywords = json["keywords"]  as! [String]
        }
    }
}

class CheckUpgradeRequest : ServerRequest {
    
}

class CheckUpgradeResponse : ServerResponse {
    var newestVersion = ""
    var isNeedUpgrade = false
    var upgradeType = "optional"
    var upgradeUrl = "http://www.baidu.com"
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        if status == 0 {
            isNeedUpgrade = json["isNeedUpgrade"]  as! Bool
            if json["newestVersion"] != nil && !(json["newestVersion"] is NSNull) {
                newestVersion = json["newestVersion"] as! String
            }
            if isNeedUpgrade {
                upgradeType = json["upgradeType"] as! String
                upgradeUrl = json["upgradeUrl"] as! String
            }
        }
    }
}


class RegisterDeviceRequest : ServerRequest {
    var deviceToken = ""
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["deviceToken"] = deviceToken as AnyObject
            return parameters
        }
    }
}

class RegisterDeviceResponse : ServerResponse {
    
}

class SetNameRequest : ServerRequest {
    var newName = ""
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["newName"] = newName as AnyObject
            return parameters
        }
    }
}

class SetNameResponse : ServerResponse {
    
}

class SetNickNameRequest : ServerRequest {
    var newNickName = ""
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["newNickName"] = newNickName as AnyObject
            return parameters
        }
    }
}

class SetNickNameResponse : ServerResponse {
    
}

class SetSexRequest : ServerRequest {
    var newSex = ""
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["newSex"] = newSex as AnyObject
            return parameters
        }
    }
}

class SetSexResponse : ServerResponse {
    
}



class GetAdsRequest : ServerRequest {
    
}

class GetAdsResponse : ServerResponse {
    var ads = [Advertise]()
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        if status == 0 {
            let adsJson = json["ads"] as! NSArray
            for adJson1 in adsJson {
                let adJson = adJson1 as! [String:AnyObject]
                let ad = Advertise()
                ad.imageUrl = adJson["imageUrl"] as! String
                ad.clickUrl = adJson["clickUrl"] as! String
                ad.title = adJson["title"] as! String
                ads.append(ad)
            }
            
        }
    }
}

class GetUserStatDataRequest : ServerRequest {
    
}
class GetUserStatDataResponse : ServerResponse {
    var jifen: String!
    var chaifu: String!
    var teamPeople: String!
    var tuijianPeople: String!
    var orderCount: String!
    var zhidian : Double = 0
    
    var name : String?
    var nickName: String!
    var level: String!
    var boss: String?
    var sex: String = ""
    var codeImageUrl: String = ""
    var isBindWeixin: Bool! = false
    var hasNewMessage : Bool! = false
    var hasBindPhone : Bool! = false
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        
        let j = JSON(json)
        jifen = j["jifen"].stringValue
        chaifu = j["chaifu"].stringValue
        teamPeople = j["teamPeople"].stringValue
        tuijianPeople = j["tuijianPeople"].stringValue
        orderCount = j["orderCount"].stringValue
        
        name = j["name"].stringValue
        nickName = j["nickname"].stringValue
        
        level = j["level"].stringValue
        boss = j["boss"].stringValue
        sex = j["sex"].stringValue
        codeImageUrl = j["codeImageUrl"].stringValue
        
        if j["zhidian"].double != nil {
            zhidian = j["zhidian"].doubleValue
        }
        
        isBindWeixin = j["isBindWeixin"].boolValue
        hasNewMessage = j["hasNewMessage"].boolValue
        hasBindPhone = j["hasBindPhone"].boolValue
    }
}


class GetServiceLocatorRequest : ServerRequest {
    
}

class GetServiceLocatorResponse : ServerResponse {
    var http: String!
    var serverName: String!
    var port: Int!
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let jsonObject = json["result"] as! NSDictionary
        http = jsonObject["http"] as! String
        serverName = jsonObject["serverName"] as! String
        port = jsonObject["port"] as! Int
    }
}

class GetSongInfoRequest : ServerRequest {
    var song: Song!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["id"] = song.id as AnyObject
            return parameters
        }
    }
}

class GetSongInfoResponse : ServerResponse {
    var song: Song!
    
    private func parseAlbum(albumJson: NSDictionary) -> Album {
        let album = Album()
        album.id = "\(albumJson["id"] as! NSNumber)"
        album.name = albumJson["name"] as! String
        album.author = albumJson["author"] as! String
        album.image = albumJson["image"] as! String
        album.count = albumJson["count"] as! Int
        album.desc = albumJson["desc"] as! String
        album.listenCount = albumJson["listenCount"] as! String
        album.courseType = CourseType.getCourseType(code: albumJson["type"] as! String)!
        album.playing = albumJson["playing"] as! Bool
        album.isReady = albumJson["isReady"] as! Bool
        return album

    }
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let req = request as! GetSongInfoRequest
        let jsonObject = json["song"] as! NSDictionary

        let album = req.song.album
        if (album?.isLive)!  {
            let liveSong = LiveSong()
            liveSong.startDateTime = jsonObject["startTime"] as? String
            liveSong.endDateTime = jsonObject["endTime"] as? String
            liveSong.listenPeople = jsonObject["listenPeople"] as! String
            liveSong.hasAdvImage = jsonObject["hasAdvImage"] as! Bool
            if liveSong.hasAdvImage! {
                liveSong.advImageUrl = jsonObject["advImageUrl"] as? String
                liveSong.advUrl = jsonObject["advUrl"] as? String
            }
            
            liveSong.advScrollRate = jsonObject["advScrollRate"] as! Int

            liveSong.advText = jsonObject["advText"] as! String
            let adImages = jsonObject["advImages"] as! NSArray
            for adImageJson1 in adImages {
                let adImageJson = adImageJson1 as! [String: AnyObject]
                let adImage = Advertise()
                adImage.imageUrl = adImageJson["imageurl"] as! String
                adImage.clickUrl = adImageJson["link"] as! String
                adImage.title = adImageJson["title"] as! String
                liveSong.scrollAds.append(adImage)
            }

            song = liveSong
        } else {
            song = Song()
        }
        song.album = parseAlbum(albumJson: jsonObject["album"] as! NSDictionary)
        song.name = jsonObject["name"] as! String
        song.desc = jsonObject["desc"] as! String
        song.date = jsonObject["date"] as! String
        song.url = jsonObject["url"] as! String
        song.id = jsonObject["id"] as! String
        song.imageUrl = jsonObject["image"] as! String
        song.shareTitle = jsonObject["shareTitle"] as! String
        song.shareUrl = jsonObject["shareUrl"] as! String
        let settings = SongSetting()
        song.settings = settings
        let settingsJson = jsonObject["settings"] as! NSDictionary
        settings.canComment = settingsJson["canComment"] as! Bool
        settings.maxCommentWord = settingsJson["maxCommentWord"] as! Int
    }
}

class GetParameterInfoRequest : ServerRequest {
    var keys: [String] = []
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            do {
                let paramsJSON = JSON(keys)
                let paramsString = paramsJSON.rawString(String.Encoding.utf8)
                parameters["keywords"] = paramsString as AnyObject

            }catch let error as NSError{
                print(error.description)
            }
            return parameters
        }
    }
}

class GetParameterInfoResponse : ServerResponse {
    static let LIVE_DESCRIPTION = "livedescription"
    static let PAY_DESCRIPTION = "vipdescription"
    static let LIVE_COURSE_NAME = "liveCourseName"
    static let PAY_COURSE_NAME = "payCourseName"
    
    var map: [String: String] = [:]
    
    func getValue(key: String, defaultValue: String = "") -> String {
        if map[key] == nil {
            return defaultValue
        }
        return map[key]!
    }
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let jsonArray = json["result"] as! NSArray
        for eachJson1 in jsonArray {
            let eachJson = eachJson1 as! [String:AnyObject]
            let key = eachJson["keyword"] as! String
            let value = eachJson["value"] as! String
            map[key] = value
        }
        
    }
}

class HeartbeatRequest : ServerRequest {
    var song: Song!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["id"] = song.id as AnyObject
            return parameters
        }
    }
}

class HeartbeatResponse : ServerResponse {
    
}

class JoinRoomRequest : ServerRequest {
    var song: Song!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["id"] = song.id as AnyObject
            return parameters
        }
    }
}


class NotifyIAPSuccessRequest : ServerRequest {
    var orderId: String!
    var receipt: String!
    var productId: String!
    var sign: String!
    var payTime: String!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["productId"] = productId as AnyObject
            parameters["sign"] = sign as AnyObject
            parameters["payTime"] = payTime as AnyObject
            parameters["orderId"] = orderId as AnyObject
            parameters["receipt"] = receipt as AnyObject
            return parameters
        }
    }
}

class NotifyIAPSuccessResponse : ServerResponse {
    
}

class GetHeaderAdvRequest : ServerRequest {

}

class HeaderAdv {
    static let Type_Song = "song"
    static let Type_AlbumList = "albumlist"
    static let Param_Key_Song = "songid"
    
    var imageUrl: String! = ""
    var type: String! = ""
    var songId: String! = ""
}

class GetHeaderAdvResponse : ServerResponse {
    var headerAdv: HeaderAdv?
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let jsonArray = json["result"] as! NSArray
        for eachJson1 in jsonArray {
            let eachJson = eachJson1 as! [String:AnyObject]
            self.headerAdv = HeaderAdv()
            self.headerAdv?.imageUrl = eachJson["imageUrl"] as! String
            self.headerAdv?.type = eachJson["type"] as! String
            
            let paramsArr = eachJson["Params"] as! NSArray;
            if self.headerAdv?.type == HeaderAdv.Type_Song {
                for eachParamJson1 in paramsArr {
                    let eachParamJson = eachParamJson1 as! [String:AnyObject]
                    if eachParamJson["key"] as! String == HeaderAdv.Param_Key_Song {
                        self.headerAdv?.songId = eachParamJson["value"] as! String
                    }
                }
            }
        }
    }
}

class GetFooterAdvsRequest : ServerRequest {}
class FooterAdv {
    var imageUrl: String! = ""
    var title: String! = ""
    var url: String! = ""

}
class GetFooterAdvsResponse : ServerResponse {
    var advList = [FooterAdv]()
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let jsonArray = json["result"] as! NSArray
        for eachJson1 in jsonArray {
            let eachJson = eachJson1 as! [String:AnyObject]
            let adv = FooterAdv()
            adv.imageUrl = eachJson["imageUrl"] as! String
            adv.title = eachJson["title"] as! String
            adv.url = eachJson["url"] as! String
            self.advList.append(adv)
        }
    }
}

class GetFunctionMessageRequest : ServerRequest {}
class GetFunctionMessageResponse : ServerResponse {
    var map = [String: Int]()
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let jsonArray = json["result"] as! NSArray
        for eachJson1 in jsonArray {
            let eachJson = eachJson1 as! [String:AnyObject]
            map[eachJson["code"] as! String] = eachJson["value"] as! Int
        }
    }
}

class ClearFunctionMessageRequest : ServerRequest {
    var code: String! = ""
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            var a = [String]()
            a.append(code)
            parameters["codes"] = a as AnyObject
            return parameters
        }
    }
}

class ClearFunctionMessageResponse : ServerResponse {
    
}

class ExtendFunctionResponseObject {
    var code = ""
    var name = ""
    var imageUrl = ""
    var messageCount = 0
    var action = ""
    var clickUrl = ""
    //var title = ""
    
    var isShow = false  //没有用
    init(code: String, name: String, imageUrl: String, messageCount: Int, action: String, clickUrl: String) {
        self.code = code
        self.name = name
        self.imageUrl = imageUrl
        self.messageCount = messageCount
        self.action = action
        self.clickUrl = clickUrl
        //self.title = title
    }
}

class GetFunctionInfosRequest : ServerRequest {}
class GetFunctionInfosResponse : ServerResponse {
    
    var functions = [ExtendFunctionResponseObject]()
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let jsonArray = json["result"] as! NSArray
        for eachJson1 in jsonArray {
            let eachJson = eachJson1 as! [String:AnyObject]
            let function = ExtendFunctionResponseObject(code: eachJson["code"] as! String,
                    name: eachJson["name"] as! String,
                    imageUrl: eachJson["imageUrl"] as! String,
                    messageCount: eachJson["message"] as! Int,
                    action: eachJson["action"] as! String,
                    clickUrl:  eachJson["clickUrl"] as! String)
            functions.append(function)
        }
    }
}

class GetCourseNotifyRequest : ServerRequest {}
class GetCourseNotifyResponse : ServerResponse {
    var notifies = [String]()
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let jsonArray = json["notifies"] as! NSArray
        for eachJson in jsonArray {
            notifies.append(eachJson as! String)
        }

    }
}

class GetLaunchAdvRequest : ServerRequest {}
class GetLaunchAdvResponse : ServerResponse {
    var advTitle : String! = ""
    var imageUrl : String! = ""
    var advUrl : String! = ""
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let jsonObject = json["result"] as! NSDictionary
        advTitle = jsonObject["advTitle"] as! String
        advUrl = jsonObject["advUrl"] as! String
        imageUrl = jsonObject["imageUrl"] as! String
    }
}

class GetShareImagesRequest : ServerRequest {}
class GetShareImagesResponse : ServerResponse {
    var shareImages : [String] = [String]()
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let jsonArray = json["urls"] as! NSArray
        for eachJson in jsonArray {
            shareImages.append(eachJson as! String)
        }
    }
}

class GetMainPageAdsRequest : ServerRequest {
    var type: String! = ""
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["type"] = type as AnyObject
            return parameters
        }
    }
}
class GetMainPageAdsResponse : ServerResponse {
    var ads = [Advertise]()
    var popupAd = Advertise()
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        if status == 0 {
            let adsJson = json["ads"] as! NSArray
            for adJson1 in adsJson {
                let adJson = adJson1 as! [String:AnyObject]
                let ad = Advertise()
                ad.type = adJson["type"] as! String
                ad.id = adJson["id"] as! String
                ad.imageUrl = adJson["imageUrl"] as! String
                ad.clickUrl = adJson["clickUrl"] as! String
                ad.title = adJson["title"] as! String
                ads.append(ad)
            }
            
            let popupJson = json["popupAd"] as! NSDictionary
            if popupJson["imageUrl"] != nil {
                if popupJson["type"] != nil && !(popupJson["type"] is NSNull) {
                    popupAd.type = popupJson["type"] as! String
                }
                if popupJson["id"] != nil && !(popupJson["id"] is NSNull){
                    popupAd.id = popupJson["id"] as! String
                }
                popupAd.imageUrl = popupJson["imageUrl"] as! String
                popupAd.clickUrl = popupJson["clickUrl"] as! String
                popupAd.title = popupJson["title"] as! String
            }
        }
    }
}

class GetLearnFinancesRequest : ServerRequest {}
class GetlearnFinancesResponse : ServerResponse {
    var learnFinanceItems = [LearnFinanceItem]()
    
    private func parse(_ learnFinancesJson : [JSON]) -> [LearnFinanceItem] {
        var learnFinanceItems = [LearnFinanceItem]()
        for eachJson in learnFinancesJson {
            let item = LearnFinanceItem()
            item.id = eachJson["id"].string!
            item.songId = eachJson["songId"].string!
            item.audioUrl = eachJson["audioUrl"].string!
            item.title = eachJson["title"].string!
            learnFinanceItems.append(item)
        }
        return learnFinanceItems
    }
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        learnFinanceItems = parse(j["learnFinanceItems"].arrayValue)
    }
}

class GetZhuanLanAndTuijianCoursesRequest : ServerRequest {
}
class GetZhuanLanAndTuijianCoursesResponse : ServerResponse {
    var zhuanLans = [ZhuanLan]()
    var albums = [Album]()
    var jpks = [ZhuanLan]()
    var learnFinanceItems = [LearnFinanceItem]()
    var pos : Pos?
    
    required init() {
        
    }
    
    private func parse(_ zhuanLansJson: [JSON]) -> [ZhuanLan] {
        var results = [ZhuanLan]()
        for eachJson in zhuanLansJson {
            let zhuanLan = ZhuanLan()
            zhuanLan.name = eachJson["name"].string!
            zhuanLan.latest = eachJson["latest"].string!
            zhuanLan.priceInfo = eachJson["priceInfo"].string!
            zhuanLan.updateTime = eachJson["updateTime"].string!
            zhuanLan.desc = eachJson["description"].string!
            zhuanLan.imageUrl = eachJson["imageUrl"].string!
            zhuanLan.url = eachJson["url"].string!
            zhuanLan.author = eachJson["author"].string!
            zhuanLan.authorTitle = eachJson["authorTitle"].string!
            zhuanLan.dingyue = eachJson["dingyue"].int!
            results.append(zhuanLan)
        }
        return results
    }
    
    private func parse(_ learnFinancesJson : [JSON]) -> [LearnFinanceItem] {
        var learnFinanceItems = [LearnFinanceItem]()
        for eachJson in learnFinancesJson {
            let item = LearnFinanceItem()
            item.id = eachJson["id"].string!
            item.songId = eachJson["songId"].string!
            item.audioUrl = eachJson["audioUrl"].string!
            item.title = eachJson["title"].string!
            learnFinanceItems.append(item)
        }
        return learnFinanceItems
    }
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        zhuanLans = parse(j["zhuanLans"].arrayValue)
        jpks = parse(j["jpks"].arrayValue)
        learnFinanceItems = parse(j["learnFinanceItems"].arrayValue)
        let coursesJson = j["albums"].arrayValue
        
        let posJson = j["pos"]
        if posJson["imageUrl"].stringValue != "" {
            pos = Pos()
            pos?.clickUrl = posJson["clickUrl"].stringValue
            pos?.imageUrl = posJson["imageUrl"].stringValue
            pos?.title = posJson["title"].stringValue
        }
        
        for albumJson in coursesJson {
            let album = Album()
            album.id = "\(albumJson["id"].numberValue)"
            album.name = albumJson["name"].stringValue
            album.author = albumJson["author"].stringValue
            album.image = albumJson["image"].stringValue
            album.count = albumJson["count"].intValue
            album.desc = albumJson["desc"].stringValue
            album.listenCount = albumJson["listenCount"].stringValue
            album.courseType = CourseType.getCourseType(code: albumJson["type"].stringValue)!
            album.playing = albumJson["playing"].boolValue
            album.isReady = albumJson["isReady"].boolValue
            
            if let playTimeDesc = albumJson["playTimeDesc"].string {
                album.playTimeDesc = playTimeDesc != nil ? playTimeDesc as! String : ""
            }
            if let isAgent = albumJson["isAgent"].bool {
                album.isAgent = isAgent != nil ? isAgent as! Bool : false
            }
            
            album.status = albumJson["status"].stringValue
            album.stars = albumJson["stars"].doubleValue
            album.listenerCount = albumJson["listenerCount"].intValue
            album.liveTime = albumJson["liveTime"].stringValue
            album.date = albumJson["date"].stringValue
            
            albums.append(album)
        }
    }
}

class GetToutiaoRequest : ServerRequest {}
class GetToutiaoResponse : ServerResponse {
    var content : String = ""
    var clickUrl : String = ""
    var title : String = ""
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)["result"]
        content = j["content"].stringValue
        clickUrl = j["clickUrl"].stringValue
        title = j["title"].stringValue
        
        QL1("content is \(j["content"].stringValue)")
    }
}

class GetZhuanLansRequest : ServerRequest {
    var type: String!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["type"] = type as AnyObject
            return parameters
        }
    }
}
class GetZhuanLansResponse : ServerResponse {
    var zhuanLans = [ZhuanLan]()
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        let zhuanLansJson = j["zhuanLans"].arrayValue
        for eachJson in zhuanLansJson {
            let zhuanLan = ZhuanLan()
            zhuanLan.name = eachJson["name"].string!
            zhuanLan.latest = eachJson["latest"].string!
            zhuanLan.priceInfo = eachJson["priceInfo"].string!
            zhuanLan.updateTime = eachJson["updateTime"].string!
            zhuanLan.desc = eachJson["description"].string!
            zhuanLan.imageUrl = eachJson["imageUrl"].string!
            zhuanLan.url = eachJson["url"].string!
            zhuanLan.author = eachJson["author"].string!
            zhuanLan.authorTitle = eachJson["authorTitle"].string!
            zhuanLan.dingyue = eachJson["dingyue"].int!
            zhuanLans.append(zhuanLan)
        }
    }
}


class NewSearchResponse : ServerResponse {
    var searchResults = [SearchResult]()
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        let resultsJson = j["results"].arrayValue
        for eachJson in resultsJson {
            let searchResult = SearchResult()
            searchResult.title = eachJson["title"].string!
            searchResult.content = eachJson["content"].string!
            searchResult.clickUrl = eachJson["clickUrl"].string!
            searchResult.date = eachJson["date"].string!
            searchResult.image = eachJson["image"].string!
            searchResult.author = eachJson["author"].string!
            searchResult.desc = eachJson["desc"].string!
            
            searchResults.append(searchResult)
        }
    }
}


class GetCourseInfoRequest : ServerRequest {
    var id = ""
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["id"] = id as AnyObject
            return parameters
        }
    }
}
class GetCourseInfoResponse : ServerResponse {
    var course : Course?
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        let courseJson = j["course"]
        
        course = Course()
        course?.id = courseJson["id"].stringValue
        course?.time = courseJson["time"].stringValue
        course?.title = courseJson["title"].stringValue
        course?.introduction = courseJson["introduction"].stringValue
        
        var index = 1
        let beforeCoursesJson = courseJson["beforeCourses"].arrayValue
        for eachJSON in beforeCoursesJson {
            let child = Course()
            child.sequence = index
            child.id = eachJSON["id"].stringValue
            child.time = eachJSON["time"].stringValue
            child.title = eachJSON["title"].stringValue
            child.url = eachJSON["url"].stringValue
            course?.beforeCourses.append(child)
            index += 1
        }
    }
}

class GetQuestionsRequest : ServerRequest {}
class GetQuestionsResponse : ServerResponse {
    var questions = [Question]()
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        questions = GetQuestionsResponse.parseQuestions(j["questions"].arrayValue)
    }
    
    static func parseQuestions(_ questionsJson: [JSON]) -> [Question] {
        var results = [Question]()
        for eachJSON in questionsJson {
            let question = Question()
            results.append(question)
            
            question.id = eachJSON["id"].stringValue
            question.userId = eachJSON["userId"].stringValue
            question.userName = eachJSON["name"].stringValue
            question.time = eachJSON["time"].stringValue
            question.content = eachJSON["content"].stringValue
            question.answerCount = eachJSON["answerCount"].intValue
            question.thumbCount = eachJSON["thumbCount"].intValue
            question.isLiked = eachJSON["isLiked"].boolValue
            
            let answersJson = eachJSON["answers"].arrayValue
            for jo in answersJson {
                let answer = Answer()
                answer.fromUserId = jo["fromId"].stringValue
                answer.fromUserName = jo["fromName"].stringValue
                answer.toUserId = jo["toId"].stringValue
                answer.toUserName = jo["toName"].stringValue
                answer.content = jo["content"].stringValue
                answer.isFromManager = jo["isFromManager"].boolValue
                question.answers.append(answer)
            }
        }
        return results
    }
}

class GetFinanceToutiaoRequest : ServerRequest {}
class GetFinanceToutiaoResponse : ServerResponse {
    var toutiaos = [FinanceToutiao]()
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        let toutiaosJson = j["toutiaos"].arrayValue
        for eachJson in toutiaosJson {
            let toutiao = FinanceToutiao()
            toutiao.index = eachJson["index"].intValue
            toutiao.title = eachJson["title"].stringValue
            toutiao.content = eachJson["content"].stringValue
            toutiao.link = eachJson["link"].stringValue
            toutiaos.append(toutiao)
        }
    }
    
}

class SendAnswerRequest : ServerRequest {
    var question : Question!
    var content : String!
    var toUser = ""
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["questionId"] = question.id as AnyObject
            parameters["comment"] = content as AnyObject
            parameters["toUserId"] = toUser as AnyObject
            return parameters
        }
    }
}
class SendAnswerResponse : ServerResponse {
}

class LikeQuestionRequest : ServerRequest {
    var question : Question!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["questionId"] = question.id as AnyObject
            return parameters
        }
    }
}
class LikeQuestionResponse : ServerResponse {}

class GetPagedQuestionsRequest : PagedServerRequest {}
class GetPagedQuestionsResponse : PageServerResponse<Question> {
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        resultSet = GetQuestionsResponse.parseQuestions(j["questions"].arrayValue)
    }
}

class AskQuestionRequest : ServerRequest {
    var content : String!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["content"] = content as AnyObject
            return parameters
        }
    }
}
class AskQuestionResponse : ServerResponse {
}


class GetWeixinTokenRequest : ServerRequest {
    var code : String!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["code"] = code as AnyObject
            return parameters
        }
    }
}
class GetWeixinTokenResonse : ServerResponse {
    var responseString : String = "{}"
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        responseString = j["responseString"].stringValue
    }
}


class OAuthRequest : ServerRequest {
    var accessToken : String!
    var refreshToken : String!
    var openId : String!
    var unionId : String!
    var respStr : String!
    var deviceToken : String!
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["access_token"] = accessToken as AnyObject
            parameters["refresh_token"] = refreshToken as AnyObject
            parameters["openid"] = openId as AnyObject
            parameters["unionid"] = unionId as AnyObject
            parameters["respStr"] = respStr as AnyObject
            parameters["deviceToken"] = deviceToken as AnyObject
            return parameters
        }
    }
    
}
class OAuthResponse : LoginResponse {
}

class BindWeixinRequest : OAuthRequest {
}
class BindWeixinResponse : ServerResponse {}

class GetMessagesRequest : ServerRequest {}
class GetMessagesResponse : ServerResponse {
    var messages = [Message]()
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request: request, json: json)
        let j = JSON(json)
        let jsonArray = j["messages"].arrayValue
        for jo in jsonArray {
            let message = Message()
            message.title = jo["title"].stringValue
            message.desc = jo["detail"].stringValue
            message.time = jo["time"].stringValue
            message.clickTitle = jo["clickTitle"].stringValue
            message.clickUrl = jo["clickUrl"].stringValue
            messages.append(message)
        }
    }
}


class BindPhoneRequest : ServerRequest {
    var newPhone : String!
    var code : String! = ""
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["newphone"] = newPhone as AnyObject
            parameters["code"] = code as AnyObject
            return parameters
        }
    }
}
class BindPhoneResponse : ServerResponse {}
