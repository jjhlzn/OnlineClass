//
//  CommentListController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/19.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class CommentListController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate, CommentDelegate, PagableControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var loadingOverlay = LoadingOverlay()
    var heightDict = Dictionary<Int, CGFloat>()
    
    //comment评论窗口控制器
    var commentController = CommentController()
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var emojiSwithButton: UIButton!
    @IBOutlet weak var commentInputButton: UIButton!
    
    var keyboardHeight: CGFloat?
    var heightCache = [String: CGFloat]()
    
    var song: Song!
    
    //分页控制器
    var pagableController = PagableController<Comment>()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        print("viewDidLoad")
        //设置分页窗口的视图
        pagableController.viewController = self
        pagableController.delegate = self
        pagableController.tableView = tableView
        pagableController.initController()
        
        //设置评论窗口的视图
        commentController.bottomView = bottomView
        commentController.commentInputButton = commentInputButton
        commentController.bottomView2 = bottomView2
        commentController.commentFiled2 = commentFiled2
        commentController.cancelButton = cancelButton
        commentController.sendButton = sendButton
        commentController.emojiSwitchButton = emojiSwithButton
        commentController.viewController = self
        commentController.delegate = self
        commentController.initView(song)
      
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 260
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        commentController.addKeyboardNotify()
        pagableController.loadMore()
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
        pagableController.data.insert(comment, atIndex: 0)
        tableView.reloadData()
    }

}

extension CommentListController {
        
    //开始上拉到特定位置后改变列表底部的提示
    func scrollViewDidScroll(scrollView: UIScrollView){
        print("scrollViewDidScroll")
        pagableController.scrollViewDidScroll(scrollView)
    }
    
    
    func searchHandler(respHandler: ((resp: ServerResponse) -> Void)) {
       
        let request = GetSongCommentsRequest(song: song)
        request.pageNo = pagableController.page
        request.pageSize = ServiceConfiguration.PageSize
        
        BasicService().sendRequest(ServiceConfiguration.GET_SONG_COMMENTS,
                                   request: request,
                                   completion: respHandler as ((resp: GetSongCommentsResponse) -> Void))
        
    }
    
}

extension CommentListController {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowCount = pagableController.data.count
        if rowCount == 0 { //没有点评的情况
            return 70
        }  else {   //评论行
            
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
            let row = indexPath.row
            let comment = pagableController.data[row]
            if heightCache[comment.content] == nil {
                cell.userIdLabel.text = comment.userId
                cell.timeLabel.text = comment.time
                cell.contentLabel.text = comment.content.emojiUnescapedString
                var frame = cell.contentLabel.frame;
                cell.contentLabel.numberOfLines = 0
                cell.contentLabel.sizeToFit()
                frame.size.height = cell.contentLabel.frame.size.height;
                cell.contentLabel.frame = frame;
                var height = 35 + cell.contentLabel.bounds.height + 10
                
                if height < 65 {
                    height = 65
                }
                heightCache[comment.content] = height
                
                
            }
            //NSLog("row = \(row), height = \(heightCache[comment.content])" )
            return  heightCache[comment.content]!
        }
        
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return pagableController.data.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
        
        let comment = pagableController.data[row]
        cell.userIdLabel.text = comment.userId
        cell.timeLabel.text = comment.time
        cell.contentLabel.text = comment.content.emojiUnescapedString
        
        var frame = cell.contentLabel.frame;
        cell.contentLabel.numberOfLines = 0
        cell.contentLabel.sizeToFit()
        frame.size.height = cell.contentLabel.frame.size.height;
        cell.contentLabel.frame = frame;
        
        
        cell.userImage.becomeCircle()
        //print("computeHeight")
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

}
