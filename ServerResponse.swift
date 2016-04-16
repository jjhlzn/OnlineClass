//
//  ServerResponse.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation

class ServerResponse  {
    var status : Int = 0
    var errorMessage : String?
    required init() {}
}

class PageServerResponse : ServerResponse{
    var totalNumber : Int = 0
}

class GetAlbumsResponse : ServerResponse {
    var albums: [Album] = []
}

class GetAlbumSongsResponse : ServerResponse {
    var songs = [Song]()
}