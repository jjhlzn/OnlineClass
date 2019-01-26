//
//  SongViewController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer
import QorumLogs
import SwiftyBeaver

class SongViewController: BaseUIViewController {
    
    let log = SwiftyBeaver.self
    
    //播放页控制
    var playerPageViewController: CommonPlayerPageViewController!
    @IBOutlet weak var tableView: UITableView!
    
    //评论控件
    @IBOutlet weak var commentInputButton: UIButton!
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var commentFiled2: UITextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emojiSwithButton: UIButton!
    var commentController = CommentController()
    
    
    //播放列表视图
    @IBOutlet weak var songListView: UIView!
    var songListDataSource : SongListDataSource!
    @IBOutlet weak var songListTableView: UITableView!
    
    var overlay = UIView()
    var audioPlayer: AudioPlayer!
    var song: Song!
    
    
    var shareManager : ShareManager!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var closeShareViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        audioPlayer = getAudioPlayer()
        song = (audioPlayer.currentItem as! MyAudioItem).song
        
        //设置分享相关
        shareView.isHidden = true
        shareManager = ShareManager(controller: self)
        closeShareViewButton.addBorder(vBorder: viewBorder.Top, color: UIColor(white: 0.65, alpha: 0.5), width: 1)
        shareManager.shareTitle = song.shareTitle
        shareManager.shareUrl = song.shareUrl
        shareManager.isUseQrImage = false

        //设置评论controller
        commentController.bottomView = bottomView
        commentController.commentInputButton = commentInputButton
        commentController.bottomView2 = bottomView2
        commentController.commentFiled2 = commentFiled2
        commentController.cancelButton = cancelButton
        commentController.sendButton = sendButton
        commentController.emojiSwitchButton = emojiSwithButton
        //commentController.shareView = shareView
        commentController.viewController = self
        
        commentController.initView(song: song)
        
        //用来阻止向右滑的手势
       //self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            navigationItem.title = item.song!.name
            
            //设置播放页控制器
            log.debug(["song.isLive", item.song!.isLive])
            if item.song!.isLive {
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
        
        if song.album.isLive {
            commentController.liveDelegate = playerPageViewController as! LivePlayerPageViewController
        } else {
            commentController.delegate = playerPageViewController
        }
        
        tableView.dataSource = playerPageViewController
        tableView.delegate = playerPageViewController
        
        songListView.isHidden = true
        songListDataSource = SongListDataSource(controller: self)
        songListTableView.dataSource = songListDataSource
        songListTableView.delegate = songListDataSource

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            //tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)//导航栏如果使用系统原生半透明的，top设置为64
            //tableView.scrollIndicatorInsets = tableView.contentInset
            tableView.contentInset = UIEdgeInsetsMake(22, 0, 49, 0)
            tableView.estimatedRowHeight = 0
            UITableView.appearance().estimatedRowHeight = 0
        }
        
        playerPageViewController.reload()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commentController.addKeyboardNotify()
        
        QL1("SongViewController: viewWillAppear")
        
        //初始化playerPageViewController
        playerPageViewController.initController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commentController.removeKeyboardNotify()
        commentController.dispose()
        //dispose palyerPageViewController
        playerPageViewController.dispose()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
         playerPageViewController.reload()
    }
    

    @IBAction func shareButtonPressed(sender: AnyObject) {
        //如果正在评论，关闭评论的窗口
        if !bottomView2.isHidden {
            commentController.closeComment()
        }
        if shareView.isHidden {
            shareView.becomeFirstResponder()
            showShareView()
        } else {
            hideShareView()
        }
    }
    
    func showShareView() {
        print("showOverlay")
        overlay = UIView(frame: UIScreen.main.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
        shareView.removeFromSuperview()
        shareView.isHidden = false
        overlay.addSubview(shareView)
        self.view.addSubview(overlay)
    }
    
    func hideShareView() {
        print("hideOverlay")
        shareView.removeFromSuperview()
        self.view.addSubview(shareView)
        shareView.isHidden = true
        overlay.removeFromSuperview()
    }
    
    
    @IBAction func closeShareViewButtonPressed(sender: AnyObject) {
        hideShareView()
    }
    
    @IBAction func shareToFriends(sender: AnyObject) {
        shareManager.shareToWeixinFriend()
    }
    
    @IBAction func shareToPengyouquan(sender: AnyObject) {
        shareManager.shareToWeixinPengyouquan()
    }
    
    @IBAction func shareToWeibo(sender: AnyObject) {
        shareManager.shareToWeibo()
    }
    
    @IBAction func shareToQQFriends(sender: AnyObject) {
        shareManager.shareToQQFriend()
    }
    
    
    @IBAction func shareToQzone(sender: AnyObject) {
        shareManager.shareToQzone()
    }
    
    @IBAction func copyLink(sender: AnyObject) {
        shareManager.copyLink()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentListSegue" {
            let dest = segue.destination as! CommentListController
            dest.song = song
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        } else if segue.identifier == "advWebView" {
            let dest = segue.destination as! WebPageViewController
            let params = sender as! [String: String]
            dest.title = params["title"]
            dest.url = NSURL(string: params["url"]!)
        }
    }
    
    var songListOverlay : UIView!
    
    func showSongList() {
        print("showSongList")
        
        songListOverlay = UIView(frame: UIScreen.main.bounds)
        songListOverlay.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
        songListView.removeFromSuperview()
        songListOverlay.addSubview(songListView)
        
        view.addSubview(songListOverlay)
        
        songListView.isHidden = false
        songListTableView.reloadData()
    }
    
    func hideSongList() {
        print("hideSongList")
        songListView.isHidden = true
        songListView.removeFromSuperview()
        view.addSubview(songListView)
        songListOverlay.removeFromSuperview()
    }
    
    @IBAction func closeSongListButtonPressed(sender: AnyObject) {
        hideSongList()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = songs[indexPath.row]
        var cell : SongListCell!
        if controller.audioPlayer.isPlayThisSong(song: song) {
            cell = tableView.dequeueReusableCell(withIdentifier: "songListCell2") as! SongListCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "songListCell") as! SongListCell
        }
        cell.nameLabel.text = songs[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let audioPlayer = Utils.getAudioPlayer()
        
        //TODO
        //audioPlayer.playItems(audioPlayer.items!, startAtIndex: indexPath.row)
        
        controller.playerPageViewController.reload()
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        tableView.reloadData()

    }
}


