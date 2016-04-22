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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        comments = [Comment]()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        bottomView2.hidden = true
        commentFiled2.editable = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentListController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentListController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
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
        
        commentFiled2.becomeFirstResponder()
        //showOverlay()
        bottomView2.hidden = false
        bottomView.hidden = true
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
        bottomView.hidden = false
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
        //hideOverlay()
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
            return (comments?.count)!
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
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
            let row = indexPath.row
            let comment = comments![row]
            cell.userIdLabel.text = comment.userId
            cell.timeLabel.text = comment.time
            cell.contentLabel.text = comment.content
            cell.contentLabel.numberOfLines = 0
            cell.contentLabel.sizeToFit()
            cell.userImage.becomeCircle()
            heightDict[indexPath.row] = cell.contentLabel.bounds.height
            print("computeHeight")
            return cell
        default:
            return tableView.dequeueReusableCellWithIdentifier("playerCell")!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return 415
        case 1:
            print("getHeigth")
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
            let row = indexPath.row
            let comment = comments![row]
            cell.userIdLabel.text = comment.userId
            cell.timeLabel.text = comment.time
            cell.contentLabel.text = comment.content
            cell.contentLabel.numberOfLines = 0
            cell.contentLabel.sizeToFit()
            heightDict[indexPath.row] = cell.contentLabel.bounds.height
            print("getHeigth end")
            return 25 + heightDict[indexPath.row]! + 10
        default:
            return 1
        }
    }
    
}


