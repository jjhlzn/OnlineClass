//
//  CommentController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

protocol CommentDelegate {
    func afterSendComment(comment: Comment)
}

class CommentController : NSObject, UITextViewDelegate {
    let TAG = "CommentController"
    var overlay = UIView()
    var viewController: BaseUIViewController!
    var delegate: CommentDelegate?
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    
    @IBOutlet weak var commentInputButton: UIButton!
    
    var cancelButton: UIButton!
    var sendButton: UIButton!
    
    var keyboardHeight: CGFloat?
    
    var isSendPressed = false
    var isCommentSuccess = false
    
    var song: Song!
    
    var lastCommentTime : NSDate?
    
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        //print(textView.text); //the textView parameter is the textView where text was changed
        if textView.text.length > 0 {
            enableSendButton()
        } else {
            disableSendButton()
        }
    }
    
    private func enableSendButton() {
        sendButton.enabled = true
        sendButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
    }
    
    private func disableSendButton() {
        sendButton.enabled = false
        sendButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
    }
    
    
    func initView(song: Song) {
        
        self.song = song
        
        bottomView2.hidden = true
        commentFiled2.editable = true
        
        disableSendButton()
        
        commentFiled2.delegate = self
        
        //设置评论窗口的origin
        var frame = bottomView2.frame
        frame.origin.x = 0
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        frame.origin.y = screenHeight - bottomView2.frame.height
        print("x = \(frame.origin.x), y = \(frame.origin.y)")
        bottomView2.frame = frame
        
        if cancelButton != nil {
            cancelButton.addTarget(self, action: #selector(closeComment), forControlEvents: .TouchUpInside)
        }
        
        if sendButton != nil {
            sendButton.addTarget(self, action: #selector(sendComment), forControlEvents: .TouchUpInside)
        }
        
        commentInputButton.addTarget(self, action: #selector(handleTap), forControlEvents: .TouchUpInside)
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        viewController.hideKeyboardWhenTappedAround()
        commentFiled2.becomeFirstResponder()
        
    }
    
    func closeComment() {
        viewController.dismissKeyboard()
        commentFiled2.resignFirstResponder()
    }
    
    private func getLoginUser() -> User {
        let user = User()
        user.userName = "jjh"
        return user
    }
    
    private func getCommentContent() -> String {
        let commentContent = commentFiled2.text
        return commentContent.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
    }
    
    
    
    private func checkBeforeSend() -> Bool {
        if !song.settings.canComment {
            viewController.displayMessage("对不起，已关闭评论！")
            return false
        }
        
        let commentContent = getCommentContent()
        if commentContent.length == 0 {
            viewController.displayMessage("评论不能为空")
            return false
        }
        
        if commentContent.length > song.settings.maxCommentWord {
            viewController.displayMessage("评论不能超过\(song.settings.maxCommentWord)字")
            return false
        }
        
        //检查上次评论的时间
        if lastCommentTime != nil {
            let elapsedTime = NSDate().timeIntervalSinceDate(lastCommentTime!)
            let duration = Int(elapsedTime)
            if duration < 2 {
                viewController.displayMessage("您发的太频繁了")
                return false
            }
        }
        
        return true
    }
    
    func sendComment() {
        NSLog("%s: sendComment", TAG)
        isSendPressed = true
        let commentConent = getCommentContent()
        let song = (viewController.getAudioPlayer().currentItem as! MyAudioItem).song
        if (song == nil) {
            NSLog("%s: song is null", TAG)
            return
        }
        
        if !checkBeforeSend() {
            return
        }
        
        let sendCommentRequest = SendCommentRequest()
        sendCommentRequest.song = song
        sendCommentRequest.comment = commentConent
        
        BasicService().sendRequest(ServiceConfiguration.SEND_COMMENT, request: sendCommentRequest) {
            (resp: SendCommentResponse) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                NSLog("%s: process send comment response", self.TAG)
                self.viewController.dismissKeyboard()
                self.lastCommentTime = NSDate()
                if ( resp.status == ServerResponseStatus.Success.rawValue) {
                    NSLog("%s: sucess", self.TAG)
                    self.commentFiled2.text = ""
                    self.disableSendButton()
                    
                    self.isCommentSuccess = true
                    let comment = Comment()
                    comment.song = song
                    comment.time = "现在"
                    comment.userId = self.getLoginUser().userName
                    comment.content = commentConent
                    self.delegate?.afterSendComment(comment)
                    
                } else {
                    NSLog("%s: fail", self.TAG)
                    self.isCommentSuccess = false
                }
            }
                                    
        }
        
    }
    
    //注册键盘改变通知
    func addKeyboardNotify() {
        print("addKeyboardNotify")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide(_:)),  name: UIKeyboardDidHideNotification, object: nil)
    }
    
    //取消键盘改变的通知
    func removeKeyboardNotify() {
        print("removeKeyboardNotify")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    }
    
    var isKeyboardShow = false
    func keyboardWillShow(notification: NSNotification) {
 
        print("start keyboardWillShow")
        var frame = bottomView2.frame
        print("\(self): x = \(frame.origin.x), y = \(frame.origin.y)")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            if keyboardHeight != nil {
                frame.origin.y += (keyboardHeight! - keyboardSize.height)
                keyboardHeight = keyboardSize.height
                
            } else {
                keyboardHeight = keyboardSize.height
                showOverlay()
                frame.origin.y -= keyboardSize.height
                bottomView2.hidden = false
            }
            bottomView2.frame = frame
            commentFiled2.becomeFirstResponder()
        }
        print("end keyboardWillShow")
        isKeyboardShow = true
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        if isKeyboardShow {
            NSLog("%s: keyboardWillHide", TAG)
            commentFiled2.resignFirstResponder()
            bottomView2.hidden = true
            if keyboardHeight != nil && keyboardHeight! != 0 {
                var frame = bottomView2.frame
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                    frame.origin.y += keyboardSize.height
                    keyboardHeight = nil
                    bottomView2.frame = frame
                }
                hideOverlay()
                
            }
        }
        isKeyboardShow = false
        
    }
    
    func keyboardDidHide(notification: NSNotification) {
        if isSendPressed {
            isSendPressed = false
            var message = "评论失败!"
            if isCommentSuccess {
                message = "评论成功！"
            }
            ToastMessage.showMessage(self.viewController.view, message: message)
        }
    }
    
    func showOverlay() {
        print("showOverlay")
        overlay = UIView(frame: UIScreen.mainScreen().bounds)
        overlay.backgroundColor = UIColor(white: 0.2, alpha: 0.4)
        viewController.view.addSubview(overlay)
        
        bottomView2.removeFromSuperview()
        overlay.addSubview(bottomView2)
        viewController.hideKeyboardWhenTappedAround()
    }
    
    func hideOverlay() {
        print("hideOverlay")
        bottomView2.removeFromSuperview()
        viewController.view.addSubview(bottomView2)
        overlay.removeFromSuperview()
        viewController.cancleHideKeybaordWhenTappedAround()
    }

    
}
