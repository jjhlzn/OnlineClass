//
//  AlbumService.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation

class AlbumService : BasicService {
    
    
    func getAlbums(completion: ((resp: GetAlbumsResponse) -> Void)) -> GetAlbumsResponse {
        
        return sendRequest(ServiceConfiguration.GetAlbumsUrl, completion: completion) { (resp, dict) -> Void in
            let jsonArray = dict["albums"] as! NSArray
            var albums = [Album]()
            
            for albumJson in jsonArray {
                let album = Album()
                album.id = "\(albumJson["id"] as! NSNumber)"
                album.name = albumJson["name"] as! String
                album.author = albumJson["author"] as! String
                album.image = albumJson["image"] as! String
                albums.append(album)
            }
            resp.albums = albums
        }
    }
    
    func getSongs(album: Album, completion: ((resp: GetAlbumSongsResponse) -> Void)) -> GetAlbumSongsResponse {
        return sendRequest(ServiceConfiguration.GetAlbumSongsUrl(album.id), completion: completion) { (resp, dict) -> Void in
            let jsonArray = dict["songs"] as! NSArray
            var songs = [Song]()
            
            for json in jsonArray {
                let song = Song()
                song.name = json["name"] as! String
                song.desc = json["desc"] as! String
                song.date = json["date"] as! String
                song.url = json["url"] as! String
                song.album = album
                songs.append(song)
            }
            album.songs = songs
            resp.songs = songs
            
        }
    }
    
    func getSongComments(song: Song, pageNo: Int, pageSize: Int, completion: ((resp: GetSongCommentsResponse) -> Void)) -> GetSongCommentsResponse {
        return sendRequest(ServiceConfiguration.GetSongCommentsUrl(song.id, pageNo: pageNo, pageSize: pageSize), completion: completion) { (resp, dict) -> Void in
            
            let jsonArray = dict["comments"] as! NSArray
            var comments = [Comment]()
            
            for json in jsonArray {
                let comment = Comment()
                comment.song = song
                comment.userId = json["userId"] as! String
                comment.time = json["time"] as! String
                comment.content = json["content"] as! String
                comments.append(comment)
            }
            
            resp.comments = comments
        }
    }
    
    
    
    
}