//
//  CommentController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs
import SocketIO
import SwiftyJSON

protocol CommentDelegate {
    func afterSendComment(comment: Comment)
}

protocol LiveCommentDelegate {
    func afterSendLiveComment(comments: [Comment])
    func getLastCommentId() -> String
    func setUpdateChatFlag(isUpdateFlag: Bool)
}

class CommentController : NSObject, UITextViewDelegate {
    let TAG = "CommentController"
    var overlay = UIView()
    var viewController: BaseUIViewController!
    var delegate: CommentDelegate?
    var liveDelegate: LiveCommentDelegate?
    var bottomView: UIView!
    
    var bottomView2: UIView!
    var commentFiled2: UITextView!
    var shareView: UIView!
    
     var commentInputButton: UIButton!
    var emojiSwitchButton : UIButton?
    
    var cancelButton: UIButton!
    var sendButton: UIButton!
    
    var keyboardHeight: CGFloat?
    
    var isSendPressed = false
    var isCommentSuccess = false
    
    var song: Song!
    
    var lastCommentTime : NSDate?
    
    var emojiKeyboard : EmojiKeyboard!
    var commentErrorMessage: String?
    
    var socket: SocketIOClient?
    let loginUserStore = LoginUserStore()
    
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        //print(textView.text); //the textView parameter is the textView where text was changed
        if textView.text.length > 0 {
            enableSendButton()
        } else {
            disableSendButton()
        }
    }
    
    private func enableSendButton() {
        sendButton.isEnabled = true
        sendButton.setTitleColor(cancelButton.tintColor, for: [])
    }
    
    private func disableSendButton() {
        sendButton.isEnabled = false
        sendButton.setTitleColor(UIColor.gray, for: [])
    }
    
    
    func initView(song: Song) {
        
        self.song = song
        commentErrorMessage = "评论失败"
        
        bottomView2.isHidden = true
        commentFiled2.isEditable = true
        
        disableSendButton()
        
        commentFiled2.delegate = self
        
        //设置评论窗口的origin
        var frame = bottomView2.frame
        frame.origin.x = 0
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        frame.origin.y = screenHeight - bottomView2.frame.height
        print("x = \(frame.origin.x), y = \(frame.origin.y)")
        bottomView2.frame = frame
        
        if cancelButton != nil {
            cancelButton.addTarget(self, action: #selector(closeComment), for: .touchUpInside)
        }
        
        if sendButton != nil {
            sendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        }
        
        commentInputButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        emojiKeyboard = EmojiKeyboard(editText: commentFiled2)
        
        if emojiSwitchButton != nil {
            emojiSwitchButton?.addTarget(self, action: #selector(emojiSwitchButtonPressed), for: .touchUpInside)
        }
        
        initChat()
    }
    
    let chat_message_cmd = "chat message"
    let join_room_cmd = "join room"
    
    func initChat() {
        if socket != nil {
            return
        }
        let manager =  SocketManager(socketURL: URL(string:  ServiceLinkManager.ChatUrl)!, config: [.log(true), .compress])
        socket = manager.defaultSocket
        socket!.on("connect") {data, ack in
            QL1("socket connected")
            let request = JoinRoomRequest()
            request.song = self.song
            self.socket?.emit(self.join_room_cmd, request.getJSON().rawString()!)
        }
        
        socket!.on(chat_message_cmd) {data, ack in
            //get new message
            QL1("got a new message")
            QL1(data)
            let commentJson = JSON.parse(data[0] as! String)
            let comment = Comment()
            comment.content = commentJson["content"].stringValue
            comment.nickName = commentJson["name"].stringValue
            comment.userId = commentJson["userId"].stringValue
            comment.id = commentJson["id"].stringValue
            comment.time = commentJson["time"].stringValue
            comment.isManager = commentJson["isManager"].boolValue
            self.liveDelegate?.afterSendLiveComment(comments: [comment])
            
        }
        
        socket!.connect()
    }
    
    func dispose() {
        if socket != nil {
            socket!.off(chat_message_cmd)
            socket!.off(join_room_cmd)
            socket!.disconnect()
        }
    }
    
    
    var isEmojiKeyboardOpen = false
    var emojiKeyboardView : UIView?
    @objc func emojiSwitchButtonPressed(sender: UIButton) {
        //如果是键盘模式，则关闭键盘，打开emoji键盘
        if !isEmojiKeyboardOpen {
            openEmojiKeyboard()
        } else {
            closeEmojiKeyboard()
            commentFiled2.becomeFirstResponder()
        }
    }
    
    
    private func openEmojiKeyboard() {
        emojiKeyboardView = emojiKeyboard.getView()
        commentFiled2.resignFirstResponder()
        viewController.view.addSubview(emojiKeyboardView!)
        showOrAdjustCommentWindow(keyboardSize: (emojiKeyboardView?.frame)!)
        emojiSwitchButton?.setImage(UIImage(named: "emojiSwitchButton2"), for: [])
        isEmojiKeyboardOpen = true
        //调整评论框的y坐标
    }
    
    private func closeEmojiKeyboard() {
        //如果是emoji键盘，则关闭emoji键盘，打开键盘
        emojiKeyboardView?.removeFromSuperview()
        
        emojiSwitchButton?.setImage(UIImage(named: "emojiSwitchButton1"), for: [])
        
        isEmojiKeyboardOpen = false
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        //viewController.hideKeyboardWhenTappedAround()
        commentFiled2.becomeFirstResponder()
        
    }
    
    @objc func closeComment() {
        closeCommentWindow()
        if emojiKeyboardView != nil {
            closeEmojiKeyboard()
        }
        viewController.dismissKeyboard()
        commentFiled2.resignFirstResponder()
    }
    
    
    private func getCommentContent() -> String {
        let commentContent = commentFiled2.text.emojiEscapedString
        //TODO: 去掉前后空格
        return commentContent
        //return commentContent.stringByTrimmingCharactersInSet(
          //  NSCharacterSet.whitespaceAndNewlineCharacterSet()
       // )
    }
    
    
    
    private func checkBeforeSend() -> Bool {
        
        let commentContent = getCommentContent()
        if commentContent.length == 0 {
            viewController.displayMessage(message: "评论不能为空")
            return false
        }
        
        //检查上次评论的时间
        if lastCommentTime != nil {
            let elapsedTime = NSDate().timeIntervalSince(lastCommentTime! as Date)
            let duration = Int(elapsedTime)
            if duration < 2 {
                viewController.displayMessage(message: "您发的太频繁了")
                return false
            }
        }
        
        return true
    }
    
    @objc func sendComment() {
        NSLog("%s: sendComment", TAG)
        isSendPressed = true
        
        let song = (viewController.getAudioPlayer().currentItem as! MyAudioItem).song
        if (song == nil) {
            NSLog("%s: song is null", TAG)
            return
        }
        
        if !checkBeforeSend() {
            return
        }
        
        //关闭评论窗口
        closeCommentWindow()
        
        if (song?.isLive)! {
            sendLiveComment()
        } else {
            sendCommonComment()
        }
        
    }
    
    private func sendCommonComment() {
        let sendCommentRequest = SendCommentRequest()
        sendCommentRequest.song = song
        sendCommentRequest.comment = getCommentContent().emojiEscapedString
        
        BasicService().sendRequest(url: ServiceConfiguration.SEND_COMMENT, request: sendCommentRequest) {
            (resp: SendCommentResponse) -> Void in
            DispatchQueue.main.async() {
                NSLog("%s: process send comment response", self.TAG)
                self.viewController.dismissKeyboard()
                self.lastCommentTime = NSDate()
                if ( resp.status == ServerResponseStatus.Success.rawValue) {
                    NSLog("%s: sucess", self.TAG)
                    self.commentFiled2.text = ""
                    self.disableSendButton()
                    
                    let loginUser = self.loginUserStore.getLoginUser()
                    
                    self.isCommentSuccess = true
                    let comment = Comment()
                    comment.song = self.song
                    comment.time = "现在"
                    comment.userId = loginUser!.userName
                    comment.nickName = loginUser!.nickName!
                    comment.content = sendCommentRequest.comment
                    self.delegate?.afterSendComment(comment: comment)
                    
                    if !self.isKeyboardShow {
                        self.showComentResultTip()
                    }
                    
                } else {
                    NSLog("%s: fail", self.TAG)
                    self.isCommentSuccess = false
                    self.commentErrorMessage = resp.errorMessage
                }
            }
            
        }

    }
    
    
    private func sendLiveComment() {

        //liveDelegate?.setUpdateChatFlag(true)
        let sendCommentRequest = SendLiveCommentRequest()
        sendCommentRequest.song = song
        sendCommentRequest.lastId = liveDelegate!.getLastCommentId()
        sendCommentRequest.comment = getCommentContent().emojiEscapedString
        
        //在每次发送评论之前，都尝试重新连接
        socket?.connect()
        //socket?.reconnect()
        QL1("sendCommentRequest = \(sendCommentRequest.getJSON().rawString())")

        socket?.emitWithAck(chat_message_cmd, sendCommentRequest.getJSON().rawString()!).timingOut(after: 0) { data in
            QL1("emitWithAck callback")
            QL1(data)

            let result = data[0] as! NSDictionary
            if result["status"] as! Int != 0 {
                self.viewController.displayMessage(message: result["errorMessage"] as! String )
                return
            }
            
            self.viewController.dismissKeyboard()
            self.lastCommentTime = NSDate()
            self.commentFiled2.text = ""
            self.disableSendButton()
            self.isCommentSuccess = true
            if !self.isKeyboardShow {
                self.showComentResultTip()
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            
            
            let loginUser = self.loginUserStore.getLoginUser()
            
            let comment = Comment()
            comment.id = "1"
            comment.song = self.song
            comment.time = dateFormatter.string(from: NSDate() as Date)
            comment.userId = loginUser!.userName
            comment.nickName = loginUser!.nickName!
            comment.content = sendCommentRequest.comment
            self.liveDelegate?.afterSendLiveComment(comments: [comment])
        }
    }

    
    
    //注册键盘改变通知
    func addKeyboardNotify() {
        print("addKeyboardNotify")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide),  name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    //取消键盘改变的通知
    func removeKeyboardNotify() {
        print("removeKeyboardNotify")
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    
    var isKeyboardShow = false
    
    @objc func keyboardWillShow(notification: NSNotification) {
 
        print("start keyboardWillShow")
        //notification.userInfo?[UIKeyboardFrameEndUserInfoKey]
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            closeEmojiKeyboard()
            showOrAdjustCommentWindow(keyboardSize: keyboardSize)
        }
    }
    
    
    //显示评论窗口，如果键盘大小发生变化，也需要调整窗口的位置
    private func showOrAdjustCommentWindow(keyboardSize: CGRect) {
        //如果分享页面打开，则不要弹出键盘
        if !shareView.isHidden {
            return
        }
        
        let screenHeight = UIScreen.main.bounds.height
        print("keyboardHeight = \(keyboardSize.height)")
        let commentWinY = screenHeight - keyboardSize.height - bottomView2.frame.height
        bottomView2.frame.origin.y = commentWinY

        if !isKeyboardShow {
            isKeyboardShow = true
            showOverlay()
            bottomView2.isHidden = false
            emojiSwitchButton?.setImage(UIImage(named: "emojiSwitchButton1"), for: [])
            //这个要放在显示bottomView2之后才掉用
            commentFiled2.becomeFirstResponder()
        }

    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        emojiSwitchButton?.setImage(UIImage(named: "emojiSwitchButton2"), for: [])
    }
    
    
    func closeCommentWindow() {
        
        if isKeyboardShow {
            commentFiled2.resignFirstResponder()
            bottomView2.isHidden = true
            
            let screenHeight = UIScreen.main.bounds.height
            let commentWinY = screenHeight - bottomView2.frame.height
            bottomView2.frame.origin.y = commentWinY

            
            hideOverlay()
            isKeyboardShow = false
        }
        
        closeEmojiKeyboard()
    }
    
    
    @objc func keyboardDidHide(notification: NSNotification) {
        if isSendPressed {
            showComentResultTip()
        }
    }
    
    private func showComentResultTip() {
        isSendPressed = false
        var message = commentErrorMessage != nil ? commentErrorMessage! : "评论失败"
        if isCommentSuccess {
            message = "评论成功！"
        }
        ToastMessage.showMessage(view: self.viewController.view, message: message)
    }
    
    func showOverlay() {
        print("showOverlay")
        overlay = UIView(frame: UIScreen.main.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
        
        bottomView2.removeFromSuperview()
        overlay.addSubview(bottomView2)
        viewController.view.addSubview(overlay)
        //viewController.hideKeyboardWhenTappedAround()
    }
    
    func hideOverlay() {
        print("hideOverlay")
        bottomView2.removeFromSuperview()
        viewController.view.addSubview(bottomView2)
        bottomView2.isHidden = true
        overlay.removeFromSuperview()
        //viewController.cancleHideKeybaordWhenTappedAround()
    }
}
