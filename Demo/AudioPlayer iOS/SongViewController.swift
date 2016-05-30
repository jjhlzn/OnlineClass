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
    @IBOutlet weak var commentInputButton: UIButton!
    @IBOutlet weak var commentInputTip: UILabel!
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var commentController = CommentController()
    
    
    //播放列表视图
    @IBOutlet weak var songListView: UIView!
    var songListDataSource : SongListDataSource!
    @IBOutlet weak var songListTableView: UITableView!
    
    var overlay = UIView()
    var audioPlayer: AudioPlayer!
    var song: Song!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        audioPlayer = getAudioPlayer()
        song = (audioPlayer.currentItem as! MyAudioItem).song

        //设置评论controller
        commentController.bottomView = bottomView
        commentController.commentInputButton = commentInputButton
        commentController.bottomView2 = bottomView2
        commentController.commentFiled2 = commentFiled2
        commentController.cancelButton = cancelButton
        commentController.sendButton = sendButton
        commentController.viewController = self
        commentController.delegate = self
        commentController.initView(song)
        

        //用来阻止向右滑的手势
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
        
        songListView.hidden = true
        songListDataSource = SongListDataSource(controller: self)
        songListTableView.dataSource = songListDataSource
        songListTableView.delegate = songListDataSource
    
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
            let dest = segue.destinationViewController as! CommentListController
            dest.song = song
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    var songListOverlay : UIView!
    
    func showSongList() {
        print("showSongList")
        
       
        
        songListOverlay = UIView(frame: UIScreen.mainScreen().bounds)
        songListOverlay.backgroundColor = UIColor(white: 0.2, alpha: 0.4)
        
        songListView.removeFromSuperview()
        songListOverlay.addSubview(songListView)
        
        view.addSubview(songListOverlay)
        
        songListView.hidden = false
    }
    
    func hideSongList() {
        print("hideSongList")
        songListView.hidden = true
        songListView.removeFromSuperview()
        view.addSubview(songListView)
        songListOverlay.removeFromSuperview()
    }
    
    @IBAction func closeSongListButtonPressed(sender: AnyObject) {
        hideSongList()
    }
    
    /****************************private method************************************/
    
    func reload() {
        
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            
            
            song = item.song
            commentController.song = song
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


class SongListDataSource : NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var songs : [Song]!
    var controller : SongViewController!
    
    init(controller: SongViewController) {
        self.controller = controller
        let audioPlayer = Utils.getAudioPlayer()
        songs = (audioPlayer.items)!.map {
            return ($0 as! MyAudioItem).song
        }
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songListCell") as! SongListCell
        cell.nameLabel.text = songs[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let audioPlayer = Utils.getAudioPlayer()
        audioPlayer.playItems(audioPlayer.items!, startAtIndex: indexPath.row)
        controller.reload()
    }
}


