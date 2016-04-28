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
    
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    var overlay = UIView()
    
    var keyboardHeight: CGFloat?
    
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
              heightDict[indexPath.row] = cell.contentLabel.bounds.height
        cell.userImage.becomeCircle()
        return cell
        
    }
    
    
    
}
