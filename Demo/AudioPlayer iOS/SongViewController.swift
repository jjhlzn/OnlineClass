//
//  SongViewController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer

class SongViewController: BaseUIViewController, UIGestureRecognizerDelegate, CommentDelegate {
    
    //播放页控制
    var playerPageViewController: CommonPlayerPageViewController!
    @IBOutlet weak var tableView: UITableView!
    
    //评论控件
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var commentController = CommentController()
    
    var overlay = UIView()
    var audioPlayer: AudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置评论controller
        commentController.bottomView = bottomView
        commentController.commentField = commentField
        commentController.bottomView2 = bottomView2
        commentController.commentFiled2 = commentFiled2
        commentController.cancelButton = cancelButton
        commentController.sendButton = sendButton
        commentController.viewController = self
        commentController.delegate = self
        commentController.initView()
        
        audioPlayer = getAudioPlayer()
        
       
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            navigationItem.title = item.song!.name
            
            //设置播放页控制器
            if item.song!.album.courseType == CourseType.Live {
                playerPageViewController = LivePlayerPageViewController()
            } else {
                playerPageViewController = CommonPlayerPageViewController()
            }
            
        } else {
            playerPageViewController = CommonPlayerPageViewController()
        }
        
        playerPageViewController.viewController = self
        playerPageViewController.showHasMoreLink = true
        playerPageViewController.comments = [Comment]()
        
        tableView.dataSource = playerPageViewController
        tableView.delegate = playerPageViewController
        
        reload()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        commentController.addKeyboardNotify()
        
        
        //初始化playerPageViewController
        playerPageViewController.initController()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        commentController.removeKeyboardNotify()
        
        //dispose palyerPageViewController
        playerPageViewController.dispose()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.liveProgressTimer != nil {
            appDelegate.liveProgressTimer?.invalidate()
            appDelegate.liveProgressTimer = nil
        }
    }
    
    
    
    /* UIGestureRecognizerDelegate functions   */
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    @IBAction func nextSongPressed(sender: UIButton) {
        reload()
    }
    
    func afterSendComment(comment: Comment) {
        playerPageViewController.comments.insert(comment, atIndex: 0)
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "commentListSegue" {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    
    /****************************private method************************************/
    
    private func reload() {
        
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            
            
            let song = item.song
            BasicService().sendRequest(ServiceConfiguration.GET_SONG_COMMENTS,
                                   params: ["song": song]) {
                                    (resp: GetSongCommentsResponse) -> Void in
                                    dispatch_async(dispatch_get_main_queue()) {
                                        if resp.status != 0 {
                                            print(resp.errorMessage)
                                            return
                                        }
                                        self.playerPageViewController.comments = resp.resultSet
                                        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
                                    }
          }
        }
    }
    

}


