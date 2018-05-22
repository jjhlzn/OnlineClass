//
//  CommentKeyboard.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/12.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class CommentKeyboard: BaseCustomView {

    var commentController: CommentController!
    @IBOutlet weak var keyboardTipView: UIView!
    
    @IBOutlet weak var commentInputButton: UIButton!
    @IBOutlet weak var keyboardView: UIView!
    
    @IBOutlet weak var commentField: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var switchButton: UIButton!

    init(frame: CGRect, shareView: ShareView, viewController : UIViewController, liveDelegate: LiveCommentDelegate) {
        super.init(frame: frame)
        commentController = CommentController()
        
        //设置评论controller
        commentController.bottomView = keyboardTipView
        commentController.commentInputButton = commentInputButton
        commentController.bottomView2 = keyboardView
        commentController.commentFiled2 = commentField
        commentController.cancelButton = cancelButton
        commentController.sendButton = sendButton
        commentController.emojiSwitchButton = switchButton
        commentController.shareView = shareView
        commentController.viewController = viewController
        
        commentController.liveDelegate = liveDelegate
        let song = Utils.getCurrentSong()
        commentController.initView(song: song)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    

}
