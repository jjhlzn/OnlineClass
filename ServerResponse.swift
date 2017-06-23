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
            parameters["test"] = test
            return parameters
        }
    }
    
    private func addMoreRequestInfo(params: [String: AnyObject]?) -> [String: AnyObject] {
        var newParams = [String: AnyObject]()
        newParams["request"] = params
        newParams["client"] = getClientInfo()
        newParams["userInfo"] = getUserInfo()
        return newParams
        
    }
    
    func getJSON() -> JSON {
        let finalParams = addMoreRequestInfo(params)
        return JSON(finalParams)
    }
    
    private func getClientInfo() -> [String: AnyObject]{
        var clientInfo = [String: AnyObject]()
        clientInfo["platform"] = "iphone"
        clientInfo["model"] = UIDevice.currentDevice().model
        clientInfo["osversion"] = UIDevice.currentDevice().systemVersion
        
        let screensize = UIScreen.mainScreen().bounds
        clientInfo["screensize"] = "\(screensize.width)*\(screensize.height)"
        
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let appBundle = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        clientInfo["appversion"] = "\(version).\(appBundle)"
        return clientInfo
        
    }
    
    
    private func getUserInfo() -> [String: AnyObject] {
        let loginUserStore = LoginUserStore()
        var userInfo = [String: AnyObject]()
        let loginUser = loginUserStore.getLoginUser()
        userInfo["userid"] = loginUser?.userName!
        userInfo["token"] = loginUser?.token!
        return userInfo
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
        super.parseJSON(request, json: json)
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
            album.count = albumJson["count"] as! Int
            album.desc = albumJson["desc"] as! String
            album.listenCount = albumJson["listenCount"] as! String
            album.courseType = CourseType.getCourseType(albumJson["type"] as! String)!
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
                
                liveSong.advScrollRate = json["advScrollRate"] as! Int
                liveSong.advText = json["advText"] as! String
                let adImages = json["advImages"] as! NSArray
                for adImageJson in adImages {
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
        
        for eachJSON in jsonArray {
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
            comment.nickName = json["name"] as! String
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

class SendLiveCommentRequest : ServerRequest {
    var song: Song!
    var lastId: String!
    var comment: String!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["song"] = ["id": song.id]
            parameters["lastId"] = lastId
            parameters["comment"] = comment
            return parameters
        }
    }
}

class SendLiveCommentResponse : ServerResponse {
    var comments = [Comment]()
    required init() {}
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
        
        let jsonArray = json["comments"] as! NSArray
        comments = [Comment]()
        
        for eachJSON in jsonArray {
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
            parameters["userName"] = userName
            parameters["password"] = password
            parameters["deviceToken"] = deviceToken
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
    
    required init() {
        
    }
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)

        if status == 0 {
            name = json["name"] as? String
            token = json["token"] as? String
            sex = json["sex"] as! String
            codeImageUrl = json["codeImageUrl"] as! String
            nickName = json["nickname"] as! String
            level = json["level"] as! String
            boss = json["boss"] as? String
        }
    }

}

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
            parameters["userName"] = userName
            parameters["password"] = password
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
        super.parseJSON(request, json: json)
        
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

class GetHotSearchWordsRequest : ServerRequest {
    
}

class GetHotSearchWordsResponse : ServerResponse {
    var keywords = [String]()
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
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
        super.parseJSON(request, json: json)
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
            parameters["deviceToken"] = deviceToken
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
            parameters["newName"] = newName
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
            parameters["newNickName"] = newNickName
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
            parameters["newSex"] = newSex
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
        super.parseJSON(request, json: json)
        if status == 0 {
            let adsJson = json["ads"] as! NSArray
            for adJson in adsJson {
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
    
    var name : String?
    var nickName: String!
    var level: String!
    var boss: String?
    var sex: String = ""
    var codeImageUrl: String = ""

    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
        jifen = json["jifen"] as! String
        chaifu = json["chaifu"] as! String
        teamPeople = json["teamPeople"] as! String
        tuijianPeople = json["tuijianPeople"] as! String
        orderCount = json["orderCount"] as! String
        
        name = json["name"] as? String
        if json["nickname"] != nil {
            nickName = json["nickname"] as! String
        } else {
            nickName = ""
        }
        
        level = json["level"] as! String
        boss = json["boss"] as? String
        sex = json["sex"] as! String
        codeImageUrl = json["codeImageUrl"] as! String
    }
}


class GetServiceLocatorRequest : ServerRequest {
    
}

class GetServiceLocatorResponse : ServerResponse {
    var http: String!
    var serverName: String!
    var port: Int!
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
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
            parameters["id"] = song.id
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
        album.courseType = CourseType.getCourseType(albumJson["type"] as! String)!
        album.playing = albumJson["playing"] as! Bool
        album.isReady = albumJson["isReady"] as! Bool
        return album

    }
    
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
        let req = request as! GetSongInfoRequest
        let jsonObject = json["song"] as! NSDictionary

        let album = req.song.album
        if album.isLive  {
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
            for adImageJson in adImages {
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
        song.album = parseAlbum(jsonObject["album"] as! NSDictionary)
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
                let paramsString = paramsJSON.rawString(NSUTF8StringEncoding)
                parameters["keywords"] = paramsString

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
        super.parseJSON(request, json: json)
        let jsonArray = json["result"] as! NSArray
        for eachJson in jsonArray {
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
            parameters["id"] = song.id
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
            parameters["id"] = song.id
            return parameters
        }
    }
}


class NotifyIAPSuccessRequest : ServerRequest {
    var productId: String!
    var sign: String!
    var payTime: String!
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["productId"] = productId
            parameters["sign"] = sign
            parameters["payTime"] = payTime
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
        super.parseJSON(request, json: json)
        let jsonArray = json["result"] as! NSArray
        for eachJson in jsonArray {
            self.headerAdv = HeaderAdv()
            self.headerAdv?.imageUrl = eachJson["imageUrl"] as! String
            self.headerAdv?.type = eachJson["type"] as! String
            
            let paramsArr = eachJson["Params"] as! NSArray;
            if self.headerAdv?.type == HeaderAdv.Type_Song {
                for eachParamJson in paramsArr {
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
        super.parseJSON(request, json: json)
        let jsonArray = json["result"] as! NSArray
        for eachJson in jsonArray {
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
        super.parseJSON(request, json: json)
        let jsonArray = json["result"] as! NSArray
        for eachJson in jsonArray {
            map[eachJson["code"] as! String] = eachJson["value"] as! Int
        }
    }
}

class ClearFunctionMessageRequest : ServerRequest {
    var code: String! = ""
    
    override var params: [String : AnyObject] {
        get {
            var parameters = super.params
            parameters["codes"] = [code]
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
    var isShow = false
    init(code: String, name: String, imageUrl: String, messageCount: Int, isShow: Bool) {
        self.code = code
        self.name = name
        self.imageUrl = imageUrl
        self.messageCount = messageCount
        self.isShow = isShow
    }
}

class GetFunctionInfosRequest : ServerRequest {}
class GetFunctionInfosResponse : ServerResponse {
    
    var functions = [ExtendFunctionResponseObject]()
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
        let jsonArray = json["result"] as! NSArray
        for eachJson in jsonArray {
            let function = ExtendFunctionResponseObject(code: eachJson["code"] as! String,
                    name: eachJson["name"] as! String,
                    imageUrl: eachJson["imageUrl"] as! String,
                    messageCount: eachJson["message"] as! Int,
                    isShow: eachJson["isShow"] as! Bool)
            functions.append(function)

        }
    }
}

class GetCourseNotifyRequest : ServerRequest {}
class GetCourseNotifyResponse : ServerResponse {
    var notifies = [String]()
    override func parseJSON(request: ServerRequest, json: NSDictionary) {
        super.parseJSON(request, json: json)
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
        super.parseJSON(request, json: json)
        let jsonObject = json["result"] as! NSDictionary
        advTitle = jsonObject["advTitle"] as! String
        advUrl = jsonObject["advUrl"] as! String
        imageUrl = jsonObject["imageUrl"] as! String
    }
}

