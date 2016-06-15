//
//  CommentListController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/28.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit

class CommonPlayerPageViewController : NSObject, UITableViewDataSource, UITableViewDelegate, CommentDelegate {
    
    var viewController: SongViewController!
    var comments: [Comment]!
    var totalCommentCount = 0
    var showHasMoreLink = true
    
    var heightCache = [String: CGFloat]()
    
    
    func initController() {
        
    }
    
    func dispose() {
        
    }
    
    func enterBackgound() {
        print("CommonPlayerPageViewController: enterBackgound")
    }
    
    func enterForhand() {
        print("CommonPlayerPageViewController: enterForhand")
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("playerCell") as! PlayerCell
            cell.controller = viewController
            cell.initPalyer()
            
            return cell
        case 1:
            let row = indexPath.row
            let rowCount = (comments?.count)!
            if row == 0 {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("commentHeaderCell") as! CommentHeaderCell
                cell.countLabel.text = "(" + "\(self.totalCommentCount)" + ")"
                return cell
                
            } else   {
                if rowCount == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("noCommentCell")
                    return cell!
                } else if row == rowCount + 1 {  //最后一行
                    let cell = tableView.dequeueReusableCellWithIdentifier("moreCommentCell") as! MoreLinkCell
                    cell.moreCommentLabel.text = "查看全部\(self.totalCommentCount)条评论 >"
                    return cell
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

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width
            return screenWidth + 95
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
                        cell.contentLabel.text = comment.content.emojiUnescapedString
                        print(comment.content)
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
        default:
            return 1
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        switch section {
        case 0:
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.selectionStyle = .None
            break;
        case 1:
            let rowCount = (comments?.count)!
            if rowCount > 0 {
                if row == rowCount + 1 {
                    tableView.cellForRowAtIndexPath(indexPath)?.selected = false
                    viewController.performSegueWithIdentifier("commentListSegue", sender: nil)
                }
            }
            break
        default:
            break
        }
    }
    
    func reload() {
        let audioPlayer = Utils.getAudioPlayer()
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            
            
            let song = item.song
            viewController.commentController.song = song
            
            let request = GetSongCommentsRequest(song: song)
            request.pageSize = 5
            BasicService().sendRequest(ServiceConfiguration.GET_SONG_COMMENTS,
                                       request: request) {
                                        (resp: GetSongCommentsResponse) -> Void in
                                        dispatch_async(dispatch_get_main_queue()) {
                                            if resp.status != 0 {
                                                print(resp.errorMessage)
                                                return
                                            }
                                            
                                            self.totalCommentCount = resp.totalNumber
                                            self.viewController.playerPageViewController.comments = resp.resultSet
                                            self.viewController.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
                                        }
            }
        }
    }
    
    func afterSendComment(comment: Comment) {
        comments.insert(comment, atIndex: 0)
        viewController.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
    }
    
    
}