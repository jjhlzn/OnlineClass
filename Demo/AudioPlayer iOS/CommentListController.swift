//
//  CommentListController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/19.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class CommentListController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate, CommentDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var comments: [Comment]?
    var loadingOverlay = LoadingOverlay()
    let albumService = AlbumService()
    var pageNo = 0
    var heightDict = Dictionary<Int, CGFloat>()
    
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    var overlay = UIView()
    
    var keyboardHeight: CGFloat?
    var heightCache = [String: CGFloat]()
    var commentController = CommentController()
    override func viewDidLoad(){
        super.viewDidLoad()
        print("viewDidLoad")
        
        commentController.bottomView = bottomView
        commentController.commentField = commentField
        commentController.bottomView2 = bottomView2
        commentController.commentFiled2 = commentFiled2
        commentController.cancelButton = cancelButton
        commentController.sendButton = sendButton
        commentController.viewController = self
        commentController.delegate = self
        commentController.initView()
      
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 260
        let song = Song()
        song.id = "1"
    
     
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        commentController.addKeyboardNotify()
    }
    

    
    override func viewWillDisappear(animated: Bool) {
        if self.navigationController!.viewControllers.indexOf(self) == nil {
            if !bottomView2.hidden {
                dismissKeyboard()
            }
        }
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear")
        commentController.removeKeyboardNotify()
    }
    
    func afterSendComment(comment: Comment) {
        comments?.insert(comment, atIndex: 0)
        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowCount = comments?.count
        if rowCount == 0 { //没有点评的情况
            return 70
        }  else {   //评论行
            
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
            let row = indexPath.row
            let comment = comments![row]
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
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments == nil {
            return 0
        }
        return comments!.count
        
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
        
        let comment = comments![row]
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
