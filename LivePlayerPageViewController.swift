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
    let freshChatInterval: NSTimeInterval = 5
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
    
    func afterSendLiveComment(comments: [Comment]) {
        if comments.count > 0 {
            self.lastId = comments[0].id!
        }
        for var arrayIndex = comments.count - 1 ; arrayIndex >= 0 ; arrayIndex-- {
            self.comments.insert(comments[arrayIndex], atIndex: 0)
        }
        
        viewController.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
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

        //如果直播在缓冲、失败，尝试重新连接
        switch audioPlayer.state {
        case .Buffering:
            QL1("try to connect again")
            audioPlayer.playItems(audioPlayer.items!, startAtIndex: audioPlayer.currentItemIndexInQueue!)
            break
        case .Failed(let error):
            QL1("try to connect again")
            print(error)
            audioPlayer.playItems(audioPlayer.items!, startAtIndex: audioPlayer.currentItemIndexInQueue!)
            break
        default:
            break
        }

        
        if isUpdateChat {
            return
        }
        
        //如果在debug模式，则不去轮询comments
        if ServiceConfiguration.isDebug {
            return
        }
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            let song = item.song
            let request = GetSongLiveCommentsRequest(song: song, lastId: lastId)
            isUpdateChat = true
            BasicService().sendRequest(ServiceConfiguration.GET_SONG_LIVE_COMMENTS, request: request) {
                (resp: GetSongLiveCommentsResponse) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self.isUpdateChat = false
                    if resp.status != 0 {
                        print(resp.errorMessage)
                        return
                    }
                    let newComments = resp.comments
                    if newComments.count > 0 {
                        self.lastId = newComments[0].id!
                    }
                    for comment in newComments {
                        self.comments.insert(comment, atIndex: 0)
                    }
                    var section = 1
                    if (song as! LiveSong).hasAdvImage!  {
                        section = 2
                    }
                    self.viewController.tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .None)
                }
            }
            
            updateChatCount = updateChatCount + 1
            
            if updateChatCount % 3 == 0 {
                let request = GetSongInfoRequest()
                request.song = item.song
                BasicService().sendRequest(ServiceConfiguration.GET_SONG_INFO, request: request) {
                    (resp: GetSongInfoResponse) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if resp.status != ServerResponseStatus.Success.rawValue {
                            QL4(resp.errorMessage)
                            return
                        }
                        let liveSong = song as! LiveSong
                        
                        let newSong = resp.song as! LiveSong
                        if liveSong.hasAdvImage == newSong.hasAdvImage
                           && liveSong.advImageUrl == newSong.advImageUrl
                            && liveSong.advUrl == newSong.advUrl {
                            return
                        }
                        liveSong.hasAdvImage = newSong.hasAdvImage
                        liveSong.advImageUrl = newSong.advImageUrl
                        liveSong.advUrl = newSong.advUrl
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
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            let song = item.song as! LiveSong
            if song.hasAdvImage! {
                return 3
            }
        }
        return 2
   }

    
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = numberOfSectionsInTableView(tableView)
    
        switch section{
            
        case 0:
            return 1
        case 1:
            if sections == 3 {
                 return 1
            } else {
                let count = (comments?.count)!
                let result = count == 0 ? 2 : count + 1
                return result > maxCommentCount ? maxCommentCount : result
            }
        default:
            let count = (comments?.count)!
            let result = count == 0 ? 2 : count + 1
            return result > maxCommentCount ? maxCommentCount : result
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            livePlayerCell = tableView.dequeueReusableCellWithIdentifier("livePlayerCell") as? LivePlayerCell
            livePlayerCell?.controller = viewController
            livePlayerCell?.initPalyer()
            self.playerViewController = livePlayerCell?.playerViewController
            return livePlayerCell!
        case 1:
            if numberOfSectionsInTableView(tableView) == 3{
                let cell = tableView.dequeueReusableCellWithIdentifier("songAdvCell") as? SongAdvCell
                if getCurrentSong() != nil && getCurrentSong()?.advImageUrl != nil {
                    if let url = NSURL(string: (getCurrentSong()?.advImageUrl!)!) {
                        cell?.advImageView.kf_setImageWithURL(url)
                    }
                }
                return cell!
            } else {
                return getCommentCell(tableView, row: indexPath.row)
            }
            
        default:
            return getCommentCell(tableView, row: indexPath.row)
        }
    }
    
    private func getCommentCell(tableView: UITableView, row: Int) -> UITableViewCell {
        let rowCount = (comments?.count)!
        if row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("chatHeaderCell") as! CommentHeaderCell
            return cell
            
        } else   {
            if rowCount == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("noCommentCell")
                return cell!
            } else if row == rowCount + 1 {  //最后一行
                let cell = tableView.dequeueReusableCellWithIdentifier("moreCommentCell")
                return cell!
            } else {
                return getCommonCell(tableView, row: row)
            }
        }

    }
    
    
    
    private func getCommonCell(tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
        let comment = comments![row - 1]
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
            cell.userImage.kf_setImageWithURL(url)
        }

        //print("computeHeight")
        return cell
        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width
            return screenWidth * 0.5 + 95
        case 1:
            if section == 3 {
                return 40
            } else {
                return getCommentCellHeight(tableView, row: indexPath.row)
            }
        default:
            return getCommentCellHeight(tableView, row: indexPath.row)
        }
    }
    
    private func getCommentCellHeight(tableView: UITableView, row: Int) -> CGFloat {
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
                let comment = comments![row - 1]
                if heightCache[comment.content] == nil {
                    cell.userIdLabel.text = comment.userId
                    cell.timeLabel.text = comment.time
                    cell.contentLabel.text = comment.content.emojiEscapedString
                    var frame = cell.contentLabel.frame;
                    cell.contentLabel.numberOfLines = 0
                    cell.contentLabel.sizeToFit()
                    frame.size.height = cell.contentLabel.frame.size.height;
                    cell.contentLabel.frame = frame;
                    var height = 25 + cell.contentLabel.bounds.height + 10
                    
                    if height < 65 {
                        height = 65
                    }
                    heightCache[comment.content] = height
                    
                    
                }
                //NSLog("row = \(row), height = \(heightCache[comment.content])" )
                return  heightCache[comment.content]!
            }
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
            if numberOfSectionsInTableView(tableView) == 3 {
                if audioPlayer.currentItem != nil {
                    let item = audioPlayer.currentItem as! MyAudioItem
                    let song = item.song as! LiveSong
                    if song.hasAdvImage && song.advUrl != nil {
                        viewController.performSegueWithIdentifier("advWebView", sender: song.advUrl!)
                    }
                }
                
            }
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
                                            var section = 1
                                            if (song as! LiveSong).hasAdvImage!  {
                                                section = 2
                                            }
                                            self.viewController.tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .None)
                                            
                                        }
            }
        }
    }
    

    
    
}