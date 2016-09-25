//
//  LivePlayerPageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/24.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit
import KDEAudioPlayer
import QorumLogs

//1. 在线聊天最多显示100条
//2. 控制聊天的自述
//3. 每隔5s, 向服务器获取配置的信息，以及获取最新的聊天信息
class LivePlayerPageViewController : CommonPlayerPageViewController, LiveCommentDelegate {
    let maxCommentCount = 10 + 1
    //聊天刷新频率
    let freshChatInterval: NSTimeInterval = 10
    //人数更新频率
    let freshListernCountInterval: NSTimeInterval = 30
    var audioPlayer: AudioPlayer!
    
    var freshChatTimer: NSTimer!
    var updateListernerCountTimer: NSTimer!
    var isUpdateChat = false
    var livePlayerCell : LivePlayerCell?
    var lastId = "-1"
    var updateChatCount = 0
    
    override func initController() {
        super.initController()
        showHasMoreLink = false
        audioPlayer = Utils.getAudioPlayer()
        createTimer()
    }
    
    override func dispose() {
        super.dispose()
        freshChatTimer.invalidate()
        updateListernerCountTimer.invalidate()
    }
    
    override func enterBackgound() {
        super.enterBackgound()
        freshChatTimer.invalidate()
        updateListernerCountTimer.invalidate()
    }
    
    override func enterForhand() {
        super.enterForhand()
        createTimer()
    }
    
    //comments是的长度总是为1
    func afterSendLiveComment(comments: [Comment]) {
        if comments.count > 0 {
            self.lastId = comments[0].id!
        }
        self.comments.insert(comments[0], atIndex: 0)
        viewController.tableView.reloadData()
    }
    
    
    func getLastCommentId() -> String {
        return lastId
    }
    
    func setUpdateChatFlag(isUpdateFlag: Bool) {
        self.isUpdateChat = isUpdateFlag
    }
    
    private func createTimer() {
        freshChatTimer = NSTimer.scheduledTimerWithTimeInterval(freshChatInterval, target: self,
                                                                selector: #selector(checkStatusAndUpdateChat), userInfo: nil, repeats: true)
        
        updateListernerCountTimer = NSTimer.scheduledTimerWithTimeInterval(freshListernCountInterval, target: self,
                                                                           selector: #selector(updateListernerCount), userInfo: nil, repeats: true)
    }
    
    
    func checkStatusAndUpdateChat() {

        
        if audioPlayer.currentItem != nil {
            let liveSong = getCurrentSong()
            
            updateChatCount = updateChatCount + 1
            
            /*
            if audioPlayer.state == AudioPlayerState.Buffering {
                //QL1("current state is buffering, try to pause and resume")
                //audioPlayer.pause()
                //audioPlayer.resume()
            } */
            
            if updateChatCount % 3 == 0 {
                let request = GetSongInfoRequest()
                request.song = liveSong
                BasicService().sendRequest(ServiceConfiguration.GET_SONG_INFO, request: request) {
                    (resp: GetSongInfoResponse) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if resp.status != ServerResponseStatus.Success.rawValue {
                            QL4(resp.errorMessage)
                            return
                        }
                        
                        var hasChange = false
                        
                        let newSong = resp.song as! LiveSong
                        if liveSong!.hasAdvImage != newSong.hasAdvImage
                           || liveSong!.advImageUrl != newSong.advImageUrl
                            || liveSong!.advUrl != newSong.advUrl {
                            hasChange = true
                        }
                        
                        if liveSong!.advText != newSong.advText {
                            hasChange = true
                        }
                        
                        if !hasChange {
                            return
                        }
                        
                        liveSong!.hasAdvImage = newSong.hasAdvImage
                        liveSong!.advImageUrl = newSong.advImageUrl
                        liveSong!.advUrl = newSong.advUrl
                        liveSong!.advText = newSong.advText
                        self.viewController.tableView.reloadData()
                    }
                }
            }
            
        }
    }
    
    func updateListernerCount() {
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            let song = item.song as! LiveSong
            let request = GetLiveListernerCountRequest(song: song)
            BasicService().sendRequest(ServiceConfiguration.GET_LIVE_LISTERNER_COUNT, request: request) {
                (resp: GetLiveListernerCountResponse) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if resp.status != 0 {
                        print(resp.errorMessage)
                        return
                    }
                    
                    self.livePlayerCell?.peopleCountLabel.text = "\(resp.count)人"
                    song.listenPeople = "\(resp.count)人"
                }
            }
        }

    }
    
    func getCurrentSong() -> LiveSong? {
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            let song = item.song as! LiveSong
            return song
        }
        return nil
        
    }
    
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
   }

    
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        switch section{
            
        case 0:
            return 1
        case 1:
            let count = (comments?.count)!
            let result = count == 0 ? 1 : count
            return result > maxCommentCount ? maxCommentCount : result
        default:
            return 0
        }
    }
    
    var advImages : [Advertise]?
    func tapAdImageHandler(sender: UITapGestureRecognizer? = nil) {
        if advImages == nil {
            return
        }
        let scrollView = sender?.view as! UIScrollView
        print(scrollView.auk.currentPageIndex)
        let index = scrollView.auk.currentPageIndex
        if index != nil {
            let params : [String: String] = ["url": advImages![index!].clickUrl, "title": advImages![index!].title]
            self.viewController.performSegueWithIdentifier("advWebView", sender: params)
        }
    }
    
    func tapApplyButtonHandler(sender: UITapGestureRecognizer? = nil) {
        let params : [String: String] = ["url": ServiceLinkManager.ApplyUrl, "title": "报名"]
        self.viewController.performSegueWithIdentifier("advWebView", sender: params)
    }
    
    //let adImageRatio : CGFloat = 0.45625
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let song = getCurrentSong()
            livePlayerCell = tableView.dequeueReusableCellWithIdentifier("livePlayerCell") as? LivePlayerCell
            livePlayerCell?.controller = viewController
            livePlayerCell?.initPalyer()
            self.playerViewController = livePlayerCell?.playerViewController
            //设置广告
            if song?.advText == "" || song?.advText == nil {
                livePlayerCell!.advTextLabel.text = "欢迎大家收听"
            } else {
                livePlayerCell!.advTextLabel.text = song?.advText
            }
            
            //设置报名按钮
            let tapApplyButtonGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapApplyButtonHandler))
            livePlayerCell!.applyButton.addGestureRecognizer(tapApplyButtonGesture)
            livePlayerCell!.applyButton.userInteractionEnabled = true
            if (song?.hasAdvImage)! {
                livePlayerCell!.applyButton.hidden = false
                livePlayerCell!.handImage.hidden = false
            } else {
                livePlayerCell!.applyButton.hidden = true
                livePlayerCell!.handImage.hidden = true
            }

            //创建滚动广告
            let imageWidth = UIScreen.mainScreen().bounds.width
            let imageHeight = getPlayerAdvHeight()
            QL2("imageWidht = \(imageWidth), imageHeight = \(imageHeight)")
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight ))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAdImageHandler))
            scrollView.addGestureRecognizer(tapGesture)
            scrollView.userInteractionEnabled = true
            
            livePlayerCell!.addSubview(scrollView)
            
            //人数需要叠在广告上面
            let peopleLabel = livePlayerCell!.peopleCountLabel
            let peopleCountImage = livePlayerCell!.peopleCountImage
            let progressBar = livePlayerCell!.progressBar
            peopleLabel.removeFromSuperview()
            peopleCountImage.removeFromSuperview()
            progressBar.removeFromSuperview()
            livePlayerCell!.addSubview(peopleLabel)
            livePlayerCell!.addSubview(peopleCountImage)
            livePlayerCell!.addSubview(progressBar)
            scrollView.auk.settings.pageControl.backgroundColor =  UIColor.grayColor().colorWithAlphaComponent(0)
            scrollView.auk.settings.contentMode = UIViewContentMode.ScaleToFill
            
            
            if song != nil {
                advImages = song?.scrollAds
                for ad in (song?.scrollAds)! {
                    // Show remote image
                    QL1("ad.imageUrl = \(ad.imageUrl)")
                    scrollView.auk.show(url: ad.imageUrl)
                }
            }
            scrollView.auk.startAutoScroll(delaySeconds: Double((song?.advScrollRate)!))
            return livePlayerCell!
        case 1:
            return getCommentCell(tableView, row: indexPath.row)
            
        default:
            return getCommentCell(tableView, row: indexPath.row)
        }
    }
    
    private func getCommentCell(tableView: UITableView, row: Int) -> UITableViewCell {
        let rowCount = (comments?.count)!
        /*
        if row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("chatHeaderCell") as! CommentHeaderCell
            return cell
            
        } else   { */
            if rowCount == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("noCommentCell")
                return cell!
            } else {
                return getCommonCell(tableView, row: row)
            }
        //}

    }
    
    
    
    private func getCommonCell(tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
        let comment = comments![row]
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
        if let url = NSURL(string: profileImageUrl) {
            cell.userImage.kf_setImageWithURL(url, placeholderImage: UIImage(named: "user"))
        }
 

        //print("computeHeight")
        return cell
        
    }
    
    
    private func getPlayerAdvHeight() -> CGFloat {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        return screenWidth * 0.5 + 8
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return getPlayerAdvHeight() + 77
        case 1:
            return getCommentCellHeight(tableView, row: indexPath.row)
        default:
            return getCommentCellHeight(tableView, row: indexPath.row)
        }
    }
    
    private func getCommentCellHeight(tableView: UITableView, row: Int) -> CGFloat {
        let rowCount = (comments?.count)!

        if rowCount == 0 { //没有点评的情况
            return 70
        }  else {   //评论行
            
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
            let comment = comments![row]

            cell.userIdLabel.text = comment.userId
            cell.timeLabel.text = comment.time
            cell.contentLabel.text = comment.content.emojiUnescapedString
            var frame = cell.contentLabel.frame;
            cell.contentLabel.numberOfLines = 0
            cell.contentLabel.sizeToFit()
            frame.size.height = cell.contentLabel.frame.size.height;
            cell.contentLabel.frame = frame;
            var height = 25 + cell.contentLabel.bounds.height + 10
            
            if height < 65 {
                height = 65
            }
            
            QL1("content = \(comment.content.emojiUnescapedString), height = \(height)")
            //NSLog("row = \(row), height = \(heightCache[comment.content])" )
            return  height
        }
        

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        switch section {
        case 0:
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.selectionStyle = .None
            break;
        case 1:
            /*
            if numberOfSectionsInTableView(tableView) == 3 {
                if audioPlayer.currentItem != nil {
                    let item = audioPlayer.currentItem as! MyAudioItem
                    let song = item.song as! LiveSong
                    if song.hasAdvImage && song.advUrl != nil {
                        viewController.performSegueWithIdentifier("advWebView", sender: song.advUrl!)
                    }
                }
                
            } */
            break
        default:
            break
        }
    }
    
    override func reload() {
        let audioPlayer = Utils.getAudioPlayer()
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            
            let song = item.song
            QL1("reload: song.id = \(song.id), song.name = \(song.name)")
            viewController.commentController.song = song
            
            playerViewController?.loadArtImage()
            
            //update comments
            let request = GetSongLiveCommentsRequest(song: song, lastId: "-1")
            BasicService().sendRequest(ServiceConfiguration.GET_SONG_LIVE_COMMENTS,
                                       request: request) {
                                        (resp: GetSongLiveCommentsResponse) -> Void in
                                        dispatch_async(dispatch_get_main_queue()) {
                                            if resp.status != 0 {
                                                print(resp.errorMessage)
                                                return
                                            }
                                            if resp.comments.count > 0 {
                                                self.lastId = resp.comments[0].id!
                                                
                                            }

                                            self.viewController.playerPageViewController.comments = resp.comments
                                            //var section = 1
                                            //if (song as! LiveSong).hasAdvImage!  {
                                            //    section = 2
                                            //}
                                            //self.viewController.tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .None)
                                            
                                        }
            }
        }
    }
    

    
    
}