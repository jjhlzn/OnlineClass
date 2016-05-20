//
//  ServiceConfiguration.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation

class ServiceConfiguration {
    static let PageSize = 20
    
    static let serverName2 = "localhost"
    static let port2 =  3000 // 19540
    
    static let serverName3 = "jjhaudio.hengdianworld.com"
    static let port3 = 80
    
    static let serverName4 = "www.jinjunhang.com"
    static let port4 = 3001
    
    static var http: String {
        get {
            return "http"
        }
    }
    
    static var serverName: String {
        get {
            return serverName3
        }
    }
    
    static var port: Int {
        get {
            return port3
        }
    }

    
    //User
    static var LOGIN : String {
        get {
            return "\(http)://\(serverName):\(port)/user/login"
        }
    }
    
    static var GET_PHONE_CHECK_CODE : String {
        get {
            return "\(http)://\(serverName):\(port)/user/getPhoneCheckCode"
        }
    }
    
    static var SIGNUP : String {
        get {
            return "\(http)://\(serverName):\(port)/user/signup"
        }
    }
    
    static var GET_PASSWORD: String {
        get {
            return "\(http)://\(serverName):\(port)/user/getPassword"
        }
    }
    
    
    //Albums
    static var GET_ALBUMS : String {
        get {
            return "\(http)://\(serverName):\(port)/albums"
        }
    }

    
    static var GET_ALBUM_SONGS: String {
        get {
            return "\(http)://\(serverName):\(port)/album/songs"
        }
    }
    
    //Songs
    static var GET_SONG_COMMENTS: String {
        get {
            return "\(http)://\(serverName):\(port)/song/comments"
        }
    }
    
    //Comment
    static var SEND_COMMENT: String {
        get {
            return "\(http)://\(serverName):\(port)/comment/add"
        }
    }
    
    
    static let ImageUrlPrefix = "http://\(serverName):\(port)/"
    static func GetSongUrl(urlSuffix: String) -> String {
        return urlSuffix
    }
    static func GetAlbumImageUrl(urlSuffix: String) -> String {
        return urlSuffix
    }




}
