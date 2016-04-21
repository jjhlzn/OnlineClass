//
//  CommentListController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/19.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class CommentListController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var comments: [Comment]?
    var loadingOverlay = LoadingOverlay()
    let albumService = AlbumService()
    var pageNo = 0
    var heightDict = Dictionary<Int, CGFloat>()
    
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    var overlay = UIView()
    var sendButton: UIButton?
    
    var keyboardHeight: CGFloat?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideKeyboardWhenTappedAround()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentListController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentListController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 260
        let song = Song()
        song.id = "1"
        
        bottomView2.hidden = true
        commentFiled2.editable = true

     
        loadingOverlay.showOverlay(view)
        albumService.getSongComments(song, pageNo: pageNo, pageSize: ServiceConfiguration.PageSize) {
            resp -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.loadingOverlay.hideOverlayView()
                if resp.status != 0 {
                    print("Server Return Error")
                    self.displayMessage(resp.errorMessage!)
                    return
                }
                
                self.comments = resp.comments
                self.tableView.reloadData()
            }
            
        }
    }
    

    @IBAction func closeComment(sender: UIButton) {
        dismissKeyboard()
        commentFiled2.endEditing(true)
        commentField.endEditing(true)
        
        
    }
    
    
    @IBAction func sendComment(sender: UIButton) {
        print(commentFiled2.text)
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let row = indexPath.row
        return 25 + heightDict[indexPath.row]! + 10
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments == nil {
            return 0
        }
        return comments!.count
        
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let comment = comments![row]
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
        cell.userIdLabel.text = comment.userId
        cell.timeLabel.text = comment.time
        cell.contentLabel.text = comment.content
        cell.contentLabel.numberOfLines = 0
        cell.contentLabel.sizeToFit()
        
        print("conentLabel.height = \(cell.contentLabel.bounds.height)")
        cell.contentLabelHeight = cell.contentLabel.bounds.height
        heightDict[indexPath.row] = cell.contentLabel.bounds.height
        cell.userImage.becomeCircle()
        return cell
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")

        commentFiled2.becomeFirstResponder()
        //showOverlay()
        bottomView2.hidden = false
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            //print("keyboardSize = \(keyboardSize.height)")
            if keyboardHeight != nil {
                self.view.frame.origin.y += (keyboardHeight! - keyboardSize.height)
                //print("diff = \(keyboardHeight! - keyboardSize.height)")
            } else {
                self.view.frame.origin.y -= keyboardSize.height
            }
            keyboardHeight = keyboardSize.height
        }
    }
    

    
    func keyboardWillHide(notification: NSNotification) {
        
        keyboardHeight = nil
        bottomView2.hidden = true
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
        //hideOverlay()
    }
    
    
    //MARK: TODO: 一旦加入overlay，会使dismisskeyboard失效
    
    func showOverlay() {
        overlay = UIView(frame: UIScreen.mainScreen().bounds)
        overlay.backgroundColor = UIColor(white: 0.6, alpha: 0.5)
        view.addSubview(overlay)
        
        bottomView.removeFromSuperview()
        overlay.addSubview(bottomView)
        bottomView2.removeFromSuperview()
        overlay.addSubview(bottomView2)
        
    }
    
    func hideOverlay() {
        
        
        bottomView.removeFromSuperview()
        view.addSubview(bottomView)
        bottomView2.removeFromSuperview()
        view.addSubview(bottomView2)
        
        overlay.removeFromSuperview()
        commentField.resignFirstResponder()
    
    }
    
}
