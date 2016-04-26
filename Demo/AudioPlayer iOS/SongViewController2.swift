//
//  SongViewController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import MediaPlayer

class SongViewController2: BaseUIViewController, UITableViewDataSource, UITableViewDelegate ,UIGestureRecognizerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    //var song: Song!
    var audioPlayer: AudioPlayer!
    
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    var keyboardHeight: CGFloat?
    var comments: [Comment]?
    
    var overlay = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCommentWindow()
        //hideKeyboardWhenTappedAround()
        comments = [Comment]()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        let song = Song()
        song.id = "1"
        AlbumService().getSongComments(song, pageNo: 0, pageSize: ServiceConfiguration.PageSize) { resp -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if resp.status != 0 {
                    print(resp.errorMessage)
                    return
                }
                self.comments = resp.comments
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            }
        }
    }
    
    
    @IBAction func sendComment(sender: AnyObject) {
    }
    
    @IBAction func closeComment(sender: AnyObject) {
    }
    
    
    
    /* UIGestureRecognizerDelegate functions   */
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    
    var heightDict = Dictionary<Int, CGFloat>()

}


extension SongViewController2 {
    
    func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        
        
        var frame = bottomView2.frame
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            if keyboardHeight != nil {
                frame.origin.y += (keyboardHeight! - keyboardSize.height)
            } else {
                showOverlay()
                frame.origin.y -= keyboardSize.height
                hideKeyboardWhenTappedAround()
                commentField.resignFirstResponder()
                commentFiled2.becomeFirstResponder()
                bottomView2.hidden = false
                
            }
            keyboardHeight = keyboardSize.height
            bottomView2.frame = frame
        }
    }

    
    func keyboardWillHide(notification: NSNotification) {
        commentFiled2.resignFirstResponder()
        cancleHideKeybaordWhenTappedAround()
        keyboardHeight = nil
        bottomView2.hidden = true
        var frame = bottomView2.frame
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            frame.origin.y += keyboardSize.height
            bottomView2.frame = frame
        }
        hideOverlay()
    }
    
    
    private func initCommentWindow() {
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
        
    }
    
    
    func showOverlay() {
        overlay = UIView(frame: UIScreen.mainScreen().bounds)
        overlay.backgroundColor = UIColor(white: 0.2, alpha: 0.4)
        view.addSubview(overlay)
        
        bottomView2.removeFromSuperview()
        overlay.addSubview(bottomView2)
    }
    
    func hideOverlay() {
        
        bottomView2.removeFromSuperview()
        view.addSubview(bottomView2)
        overlay.removeFromSuperview()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            print("comments.count = \((comments?.count)!)")
            let count = (comments?.count)!
            return count == 0 ? 2 : count + 2
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("playerCell") as! PlayerCell
            cell.initPalyer()
            
            return cell
        case 1:
            let row = indexPath.row
            let rowCount = (comments?.count)!
            if row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("commentHeaderCell") as! CommentHeaderCell
                return cell
                
            } else   {
                if rowCount == 0 {  
                    let cell = tableView.dequeueReusableCellWithIdentifier("noCommentCell")
                    return cell!
                } else if row == rowCount + 1 {  //最后一行
                    let cell = tableView.dequeueReusableCellWithIdentifier("moreCommentCell")
                    return cell!
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
                    
                    let comment = comments![row - 1]
                    cell.userIdLabel.text = comment.userId
                    cell.timeLabel.text = comment.time
                    cell.contentLabel.text = comment.content
                    cell.contentLabel.numberOfLines = 0
                    cell.contentLabel.sizeToFit()
                    cell.userImage.becomeCircle()
                    heightDict[indexPath.row] = cell.contentLabel.bounds.height
                    print("computeHeight")
                    return cell
                }
            }
        default:
            break
        }
        return tableView.dequeueReusableCellWithIdentifier("playerCell")!
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return 415
        case 1:
            let row = indexPath.row
            let rowCount = (comments?.count)!
            if row == 0 { //点评头
                return 40
            } else {
                if rowCount == 0 { //没有点评的情况
                    return 70
                } else if row == rowCount + 1 { //最后一行
                    return 44
                } else {   //评论行
                    print("getHeigth")
                    let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
                    let row = indexPath.row
                    let comment = comments![row - 1]
                    cell.userIdLabel.text = comment.userId
                    cell.timeLabel.text = comment.time
                    cell.contentLabel.text = comment.content
                    cell.contentLabel.numberOfLines = 0
                    cell.contentLabel.sizeToFit()
                    let height = cell.contentLabel.bounds.height
                    print("getHeigth end")
                    return 25 + height + 10

                }
            }
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 1:
            let rowCount = (comments?.count)!
            if rowCount > 0 {
                if row == rowCount + 1 {
                    tableView.cellForRowAtIndexPath(indexPath)?.selected = false
                    performSegueWithIdentifier("commentListSegue", sender: nil)
                }
            }
            break
        default:
            break
        }
    }
    
}


