//
//  CommentListController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/28.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit
import QorumLogs

class CommonPlayerPageViewController : NSObject, UITableViewDataSource, UITableViewDelegate, CommentDelegate {
    
    var viewController: SongViewController!
    var comments: [Comment]!
    var totalCommentCount = 0
    var showHasMoreLink = true
    var playerViewController : PlayerViewController?
    
    
    func initController() {
        
    }
    
    func dispose() {
        
    }
    
    func enterBackgound() {
        print("CommonPlayerPageViewController: enterBackgound")
    }
    
    func enterForhand() {
        print("CommonPlayerPageViewController: enterForehand")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell") as! PlayerCell
            cell.controller = viewController
            cell.initPalyer()
            self.playerViewController = cell.playerViewController
            return cell
        case 1:
            let row = indexPath.row
            let rowCount = (comments?.count)!
            if row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentHeaderCell") as! CommentHeaderCell
                cell.countLabel.text = "(" + "\(self.totalCommentCount)" + ")"
                return cell
                
            } else   {
                if rowCount == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "noCommentCell")
                    return cell!
                } else if row == rowCount + 1 {  //最后一行
                    let cell = tableView.dequeueReusableCell(withIdentifier: "moreCommentCell") as! MoreLinkCell
                    cell.moreCommentLabel.text = "查看全部\(self.totalCommentCount)条评论 >"
                    return cell
                } else {
                    return getCommonCell(tableView: tableView, row: row)
                }
            }
        default:
            break
        }
        return tableView.dequeueReusableCell(withIdentifier: "playerCell")!
        
    }
    
    private func getCommonCell(tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
        
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
        //print(profileImageUrl)
        if let url = URL(string: profileImageUrl) {
            //print("download image")
            cell.userImage.kf.setImage(with: url)
        }

        return cell

    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            let screenSize: CGRect = UIScreen.main.bounds
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
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
                    let row = indexPath.row
                    let comment = comments![row - 1]

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
                
                    return  height
                }
            }
        default:
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        switch section {
        case 0:
            let cell = tableView.cellForRow(at: indexPath as IndexPath)
            cell?.selectionStyle = .none
            break;
        case 1:
            let rowCount = (comments?.count)!
            if rowCount > 0 {
                if row == rowCount + 1 {
                    tableView.cellForRow(at: indexPath as IndexPath)?.isSelected = false
                    DispatchQueue.main.async { () -> Void in
                        self.viewController.performSegue(withIdentifier: "commentListSegue", sender: nil)
                    }
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
            
            if playerViewController != nil {
                playerViewController?.loadArtImage()
            }
            
            viewController.commentController.song = song
            QL1("reload: song.id = \(song?.id)")
            let request = GetSongCommentsRequest(song: song!)
            request.pageSize = 5
            BasicService().sendRequest(url: ServiceConfiguration.GET_SONG_COMMENTS,
                                       request: request) {
                                        (resp: GetSongCommentsResponse) -> Void in
                                        DispatchQueue.main.async() {
                                            if resp.status != 0 {
                                                print(resp.errorMessage)
                                                return
                                            }
                                            
                                            self.totalCommentCount = resp.totalNumber
                                            self.viewController.playerPageViewController.comments = resp.resultSet
                                            self.viewController.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: .none)
                                        }
            }
        }
    }
    
    func afterSendComment(comment: Comment) {
        comments.insert(comment, at: 0)
        viewController.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: .none)
    }
    
    
}
