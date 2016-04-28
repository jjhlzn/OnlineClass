//
//  SongViewController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import MediaPlayer

class SongViewController2: BaseUIViewController, UITableViewDataSource, UITableViewDelegate ,
        UIGestureRecognizerDelegate, CommentDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    var keyboardHeight: CGFloat?
    var comments: [Comment]?
    
    var overlay = UIView()
    var audioPlayer: AudioPlayer!
    
    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var cancelButton: UIButton!
    
    var commentController = CommentController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentController.bottomView = bottomView
        commentController.commentField = commentField
        commentController.bottomView2 = bottomView2
        commentController.commentFiled2 = commentFiled2
        commentController.cancelButton = cancelButton
        commentController.sendButton = sendButton
        commentController.viewController = self
        commentController.delegate = self
        commentController.initView()

        
        print("viewDidLoad")
        audioPlayer = getAudioPlayer()
        comments = [Comment]()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        if audioPlayer.currentItem != nil {
            print(audioPlayer.currentItem!.song)
            navigationItem.title = audioPlayer.currentItem!.song!.name
            print("title = \( audioPlayer.currentItem!.song!.name)")
        }
        reload()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        commentController.addKeyboardNotify()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        commentController.removeKeyboardNotify()
    }
    private func reload() {
        
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
    
    
    /* UIGestureRecognizerDelegate functions   */
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    @IBAction func nextSongPressed(sender: UIButton) {
        print("nextSongPressed")
        reload()
    }
    
    func afterSendComment(comment: Comment) {
        //情况1: 之前没有任何评论
        //情况2: 之前已经有评论了
        //comments?.insert(comment, atIndex: 0)
        comments?.insert(comment, atIndex: 0)
        /*
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([
            NSIndexPath(forRow: (comments?.count)!, inSection: 1)
            ], withRowAnimation: .Automatic)
        tableView.endUpdates() */
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        //tableView.reloadData()
    }

    var heightCache = [String: CGFloat]()

}


extension SongViewController2 {
    
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
            cell.controller = self
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
                    let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentCell
                    
                    let comment = comments![row - 1]
                    cell.userIdLabel.text = comment.userId
                    cell.timeLabel.text = comment.time
                    cell.contentLabel.text = comment.content
    
                    var frame = cell.contentLabel.frame;
                    cell.contentLabel.numberOfLines = 0
                    cell.contentLabel.sizeToFit()
                    frame.size.height = cell.contentLabel.frame.size.height;
                    cell.contentLabel.frame = frame;
                    
                    
                    cell.userImage.becomeCircle()
                    //print("computeHeight")
                    return cell
                }
            }
        default:
            break
        }
        return tableView.dequeueReusableCellWithIdentifier("playerCell")!
        
    }
    
    func addEnoughSpaceAtEnd() {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width
            return screenWidth + 95
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
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
                    let row = indexPath.row
                    let comment = comments![row - 1]
                    if heightCache[comment.content] == nil {
                        cell.userIdLabel.text = comment.userId
                        cell.timeLabel.text = comment.time
                        cell.contentLabel.text = comment.content
                        var frame = cell.contentLabel.frame;
                        cell.contentLabel.numberOfLines = 0
                        cell.contentLabel.sizeToFit()
                        frame.size.height = cell.contentLabel.frame.size.height;
                        cell.contentLabel.frame = frame;
                        var height = 25 + cell.contentLabel.bounds.height + 10
                        
                        if height < 55 {
                            height = 55
                        }
                        heightCache[comment.content] = height
                        
                        
                    }
                    //NSLog("row = \(row), height = \(heightCache[comment.content])" )
                    return  heightCache[comment.content]!
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
        case 0:
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.selectionStyle = .None
            break;
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "commentListSegue" {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
}


