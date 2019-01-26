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
    
    func searchHandler(respHandler: @escaping ((_ resp: ServerResponse) -> Void)) {
        
        let request = GetSongCommentsRequest(song: song)
        request.pageNo = pagableController.page
        request.pageSize = ServiceConfiguration.PageSize

        //TODO: 执行实际的查询
        /*
        BasicService().sendRequest(url: ServiceConfiguration.GET_SONG_COMMENTS,
                                   request: request,
                                   completion: respHandler as ((_ resp: GetSongCommentsResponse) -> Void))
        */
    }

    func afterSendComment(comment: Comment) {
        pagableController.data.insert(comment, at: 0)
        tableView.reloadData()
    }
    
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
        commentController.initView(song: song)
      
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 260
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commentController.addKeyboardNotify()
        pagableController.loadMore()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.navigationController!.viewControllers.index(of: self) == nil {
            if !bottomView2.isHidden {
                dismissKeyboard()
            }
        }
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear")
        commentController.removeKeyboardNotify()
    }
    


}

extension CommentListController {
        
    //开始上拉到特定位置后改变列表底部的提示
    func scrollViewDidScroll(scrollView: UIScrollView){
        print("scrollViewDidScroll")
        pagableController.scrollViewDidScroll(scrollView: scrollView)
    }
    
    
    
    
}

extension CommentListController {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        let rowCount = pagableController.data.count
        if rowCount == 0 { //没有点评的情况
            return 70
        }  else {   //评论行
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return pagableController.data.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
        
        let comment = pagableController.data[row]
        cell.userIdLabel.text = comment.nickName
        cell.timeLabel.text = comment.time
        cell.contentLabel.text = comment.content.emojiUnescapedString
        
        var frame = cell.contentLabel.frame;
        cell.contentLabel.numberOfLines = 0
        cell.contentLabel.sizeToFit()
        frame.size.height = cell.contentLabel.frame.size.height;
        cell.contentLabel.frame = frame;
        
        
        cell.userImage.becomeCircle()
        let profileImageUrl = ServiceConfiguration.GET_PROFILE_IMAGE + "?userid=" + comment.userId
        if let url = URL(string: profileImageUrl) {
            cell.userImage.kf.setImage(with: url)
        }

        //print("computeHeight")
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }

}
