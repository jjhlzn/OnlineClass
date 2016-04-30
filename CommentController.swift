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

class CommentController : NSObject {
    let TAG = "CommentController"
    var overlay = UIView()
    var viewController: BaseUIViewController!
    var delegate: CommentDelegate?
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    
    var cancelButton: UIButton!
    var sendButton: UIButton!
    
    var keyboardHeight: CGFloat?
    var commentService = CommentService()
    
    var isSendPressed = false
    var isCommentSuccess = false
    
    func initView() {
        
        
        bottomView2.hidden = true
        commentFiled2.editable = true
        
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
    }
    
    func closeComment() {
        viewController.dismissKeyboard()
    }
    
    private func getLoginUser() -> User {
        let user = User()
        user.userName = "jjh"
        return user
    }
    
    func sendComment() {
        NSLog("%s: sendComment", TAG)
        isSendPressed = true
        let commentConent = commentFiled2.text
        let song = viewController.getAudioPlayer().currentItem?.song
        if (song == nil) {
            NSLog("%s: song is null", TAG)
            return
        }
        commentService.sendComment(song!, user: getLoginUser(), comment: commentConent) {
            resp -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                NSLog("%s: process send comment response", self.TAG)
                self.viewController.dismissKeyboard()
                if ( resp.status == ServerResponseStatus.Success.rawValue) {
                    NSLog("%s: sucess", self.TAG)
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
    
    func addKeyboardNotify() {
        print("addKeyboardNotify")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide(_:)),  name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func removeKeyboardNotify() {
        print("removeKeyboardNotify")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        print("start keyboardWillShow")
        var frame = bottomView2.frame
        print("\(self): x = \(frame.origin.x), y = \(frame.origin.y)")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {

            if keyboardHeight != nil {
                keyboardHeight = keyboardSize.height
                frame.origin.y += (keyboardHeight! - keyboardSize.height)
                
            } else {
                keyboardHeight = keyboardSize.height
                showOverlay()
                frame.origin.y -= keyboardSize.height
                //print("here")
                viewController.hideKeyboardWhenTappedAround()
                //print("here1")
                commentField.resignFirstResponder()
                //print("here2")
                commentFiled2.becomeFirstResponder()
                //print("here3")
                bottomView2.hidden = false
            }
            
            bottomView2.frame = frame
        }
        print("end keyboardWillShow")
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        NSLog("%s: keyboardWillHide", TAG)
        commentFiled2.resignFirstResponder()
        
        bottomView2.hidden = true
        print ("keyboardHeight = \(keyboardHeight)")
        if keyboardHeight != nil && keyboardHeight! != 0 {
            var frame = bottomView2.frame
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                frame.origin.y += keyboardSize.height
                keyboardHeight = nil
                bottomView2.frame = frame
            }
            viewController.cancleHideKeybaordWhenTappedAround()
            hideOverlay()
            
        }
        
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
    }
    
    func hideOverlay() {
        print("hideOverlay")
        bottomView2.removeFromSuperview()
        viewController.view.addSubview(bottomView2)
        overlay.removeFromSuperview()
    }


}
