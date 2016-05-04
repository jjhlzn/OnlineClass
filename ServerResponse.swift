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

class ServerResponse  {
    var status : Int = 0
    var errorMessage : String?
    required init() {}
    func parseJSON(request: [String: AnyObject], json: NSDictionary) {
        status = json["status"] as! Int
        errorMessage = json["errorMessage"] as? String
    }
}

class PageServerResponse<T> : ServerResponse{
    var totalNumber : Int = 0
    var resultSet: [T] = [T]()
    required init() {}
    override func parseJSON(request: [String: AnyObject], json: NSDictionary) {
        super.parseJSON(request, json: json)
        if status == 0 {
            totalNumber = json["totalNumber"] as! Int
        }
    }
    
}

class GetAlbumsResponse : PageServerResponse<Album> {
    required init() {}
    override func parseJSON(request: [String: AnyObject], json: NSDictionary)  {
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

class GetAlbumSongsResponse : ServerResponse {
    var resultSet: [Song] = [Song]()
    required init() {}
    override func parseJSON(request: [String: AnyObject], json: NSDictionary) {
        super.parseJSON(request, json: json)
        let jsonArray = json["songs"] as! NSArray
        var songs = [Song]()
        
        for json in jsonArray {
            let song = Song()
            song.album = request["album"] as! Album
            song.name = json["name"] as! String
            song.desc = json["desc"] as! String
            song.date = json["date"] as! String
            song.url = json["url"] as! String
            songs.append(song)
            
        }
        (request["album"] as! Album).songs = songs
        resultSet = songs
    }
}

class GetSongCommentsResponse : PageServerResponse<Comment> {
    required init() {}
    override func parseJSON(request: [String: AnyObject], json: NSDictionary) {
        super.parseJSON(request, json: json)
        let jsonArray = json["comments"] as! NSArray
        var comments = [Comment]()
        
        for json in jsonArray {
            let comment = Comment()
            comment.song = request["song"] as? Song
            comment.userId = json["userId"] as! String
            comment.time = json["time"] as! String
            comment.content = json["content"] as! String
            comments.append(comment)
        }
        resultSet = comments
    }
}

class SendCommentResponse : ServerResponse {
    
}