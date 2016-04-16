//
//  ServiceConfiguration.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation

class ServiceConfiguration {
    //static let serverName = "localhost"
    static let serverName2 = "www.jinjunhang.com"
    static let serverName = "localhost"
    static let port2 = 3001
    static let port = 3000
    
    static let GetAlbumsUrl = "http://\(serverName):\(port)/albums"
    
    static let ImageUrlPrefix = "http://\(serverName):\(port)/"
    
    static func GetAlbumSongsUrl(id: String) -> String {
        return "http://\(serverName):\(port)/album/\(id)/songs"
    }
    
    static func GetSongUrl(urlSuffix: String) -> String {
        return "http://\(serverName):\(port)/\(urlSuffix)"
    }
    
    static func GetAlbumImageUrl(urlSuffix: String) -> String {
        return "\(ServiceConfiguration.ImageUrlPrefix)/\(urlSuffix)"
    }
}
