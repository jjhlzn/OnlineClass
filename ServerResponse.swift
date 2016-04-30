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
}

class PageServerResponse<T> : ServerResponse{
    var totalNumber : Int = 0
    var resultSet: [T] = [T]()
    required init() {}
}

class GetAlbumsResponse : PageServerResponse<Album> {
    required init() {}
}

class GetAlbumSongsResponse : PageServerResponse<Song> {
    required init() {}
}

class GetSongCommentsResponse : PageServerResponse<Comment> {
    required init() {}
}

class SendCommentResponse : ServerResponse {
    
}