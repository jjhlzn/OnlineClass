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

//1. 在线聊天最多显示100条
//2. 控制聊天的自述
//3. 每隔5s, 向服务器获取配置的信息，以及获取最新的聊天信息
class LivePlayerPageViewController : CommonPlayerPageViewController {
    
    //聊天刷新频率
    let freshChatInterval: NSTimeInterval = 50
    //人数更新频率
    let freshListernCountInterval: NSTimeInterval = 30
    var audioPlayer: AudioPlayer!
    
    var freshChatTimer: NSTimer!
    var updateListernerCountTimer: NSTimer!
    var isUpdateChat = false
    var livePlayerCell : LivePlayerCell?
    
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
    
    private func createTimer() {
        freshChatTimer = NSTimer.scheduledTimerWithTimeInterval(freshChatInterval, target: self,
                                                                selector: #selector(updateChat), userInfo: nil, repeats: true)
        
        updateListernerCountTimer = NSTimer.scheduledTimerWithTimeInterval(freshListernCountInterval, target: self,
                                                                           selector: #selector(updateListernerCount), userInfo: nil, repeats: true)
    }
    
    func updateChat() {
        if isUpdateChat {
            return
        }
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            let song = item.song
            let request = GetSongCommentRequest(song: song)
            isUpdateChat = true
            BasicService().sendRequest(ServiceConfiguration.GET_SONG_COMMENTS, request: request) {
                (resp: GetSongCommentsResponse) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self.isUpdateChat = false
                    if resp.status != 0 {
                        print(resp.errorMessage)
                        return
                    }
                    var newComments = resp.resultSet
                    newComments = newComments.reverse()
                    for comment in newComments {
                        self.comments.insert(comment, atIndex: 0)
                    }
                    self.viewController.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
                }
            }
        }
    }
    
    func updateListernerCount() {
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            let song = item.song
            let request = GetLiveListernerCountRequest(song: song)
            BasicService().sendRequest(ServiceConfiguration.GET_LIVE_LISTERNER_COUNT, request: request) {
                (resp: GetLiveListernerCountResponse) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if resp.status != 0 {
                        print(resp.errorMessage)
                        return
                    }
                    
                    self.livePlayerCell?.peopleCountLabel.text = "\(resp.count)人"
                    
                }
            }
        }

    }
    
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            print("comments.count = \((comments?.count)!)")
            let count = (comments?.count)!
            if showHasMoreLink {
                return count == 0 ? 2 : count + 2
            } else {
                return count == 0 ? 2 : count + 1
            }
        default:
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            livePlayerCell = tableView.dequeueReusableCellWithIdentifier("livePlayerCell") as? LivePlayerCell
            livePlayerCell?.controller = viewController
            livePlayerCell?.initPalyer()
            
            return livePlayerCell!
        case 1:
            let row = indexPath.row
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
        default:
            break
        }
        return tableView.dequeueReusableCellWithIdentifier("playerCell")!
        
    }
    
    private func getCommonCell(tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
        
        let comment = comments![row - 1]
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
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width
            return screenWidth * 0.3 + 95
        case 1:
            let row = indexPath.row
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
                    let row = indexPath.row
                    let comment = comments![row - 1]
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
        default:
            return 1
        }
    }
    
    
    
    
}