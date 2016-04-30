//
//  Model.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation


class BaseModelObject {
    
}

class Album : BaseModelObject {
    var id: String = ""
    var name: String = ""
    var author: String = ""
    var image: String = ""
    var songs = [Song]()
    
    var hasImage: Bool {
        get {
            return !image.isEmpty
        }
    }
}

class Song : BaseModelObject {
    var id: String = ""
    var name: String = ""
    var desc: String = ""
    var date: String = ""
    var url: String = ""
    var album: Album!
    var wholeUrl : String {
        return ServiceConfiguration.GetSongUrl(url)
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
}