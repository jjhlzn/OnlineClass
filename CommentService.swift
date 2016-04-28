//
//  CommentService.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation

class CommentService : BasicService {
    func sendComment(song :Song, user: User, comment: String, completion: ((resp: SendCommentResponse) -> Void)) -> SendCommentResponse {
        return postRequest(ServiceConfiguration.GetSendCommentUrl(song.id, userName: user.userName), postString: "comment=\(comment)", completion: completion) { (resp, dict) -> Void in
        }
    }
}