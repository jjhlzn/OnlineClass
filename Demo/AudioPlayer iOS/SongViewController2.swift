//
//  SongViewController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import MediaPlayer

class SongViewController2: BaseUIViewController,
        UIGestureRecognizerDelegate, CommentDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    var keyboardHeight: CGFloat?
    var comments : [Comment]?  {
        didSet{
            commentListDataSource.comments = comments
        }
    }
    
    var overlay = UIView()
    var audioPlayer: AudioPlayer!
    
    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var cancelButton: UIButton!
    var commentListDataSource: CommentListDataSourceAndDelegate!
    
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
        commentListDataSource = CommentListDataSourceAndDelegate()
        commentListDataSource.viewController = self
        commentListDataSource.showHasMoreLink = true
        
        audioPlayer = getAudioPlayer()
        comments = [Comment]()
        
        tableView.dataSource = commentListDataSource
        tableView.delegate = commentListDataSource
        
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
                self.comments = resp.resultSet
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "commentListSegue" {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }

}


