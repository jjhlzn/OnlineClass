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
import MarqueeLabel

//1. 在线聊天最多显示100条
//2. 控制聊天的自述
//3. 每隔5s, 向服务器获取配置的信息，以及获取最新的聊天信息
class LivePlayerPageViewController : CommonPlayerPageViewController, LiveCommentDelegate {
    let maxCommentCount = 10 + 1
    //聊天刷新频率
    let freshChatInterval: TimeInterval = 10
    //人数更新频率
    let freshListernCountInterval: TimeInterval = 30
    var audioPlayer: AudioPlayer!
    
    var freshChatTimer: Timer!
    var updateListernerCountTimer: Timer!
    var isUpdateChat = false
    var livePlayerCell : LivePlayerCell?
    var lastId = "-1"
    var updateChatCount = 0
    var scrollView : UIScrollView?
    
    override func initController() {
        super.initController()
        showHasMoreLink = false
        audioPlayer = Utils.getAudioPlayer()
        createTimer()
        
        let imageWidth = UIScreen.main.bounds.width
        let imageHeight = getPlayerAdvHeight()
        QL2("imageWidht = \(imageWidth), imageHeight = \(imageHeight)")
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight ))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAdImageHandler))
        scrollView!.addGestureRecognizer(tapGesture)
        scrollView!.isUserInteractionEnabled = true
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
        self.comments.insert(comments[0], at: 0)
        viewController.tableView.reloadData()
    }
    
    
    func getLastCommentId() -> String {
        return lastId
    }
    
    func setUpdateChatFlag(isUpdateFlag: Bool) {
        self.isUpdateChat = isUpdateFlag
    }
    
    private func createTimer() {
        freshChatTimer = Timer.scheduledTimer(timeInterval: freshChatInterval, target: self,
                                                                selector: #selector(checkStatusAndUpdateChat), userInfo: nil, repeats: true)
        
        updateListernerCountTimer = Timer.scheduledTimer(timeInterval: freshListernCountInterval, target: self,
                                                                           selector: #selector(updateListernerCount), userInfo: nil, repeats: true)
    }
    
    
    @objc func checkStatusAndUpdateChat() {

        
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
                BasicService().sendRequest(url: ServiceConfiguration.GET_SONG_INFO, request: request) {
                    (resp: GetSongInfoResponse) -> Void in
                    DispatchQueue.main.async() {
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
    
    @objc func updateListernerCount() {
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            let song = item.song as! LiveSong
            let request = GetLiveListernerCountRequest(song: song)
            BasicService().sendRequest(url: ServiceConfiguration.GET_LIVE_LISTERNER_COUNT, request: request) {
                (resp: GetLiveListernerCountResponse) -> Void in
                DispatchQueue.main.async() {
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
    
   override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
   }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
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
    @objc func tapAdImageHandler(sender: UITapGestureRecognizer? = nil) {
        if advImages == nil {
            return
        }
        let scrollView = sender?.view as! UIScrollView
        print(scrollView.auk.currentPageIndex)
        let index = scrollView.auk.currentPageIndex
        if index != nil {
            let params : [String: String] = ["url": advImages![index!].clickUrl, "title": advImages![index!].title]
            DispatchQueue.main.async { () -> Void in
                self.viewController.performSegue(withIdentifier: "advWebView", sender: params)
            }
        }
    }
    
    @objc func tapApplyButtonHandler(sender: UITapGestureRecognizer? = nil) {
        let params : [String: String] = ["url": ServiceLinkManager.MyAgentUrl2, "title": "报名"]
        DispatchQueue.main.async { () -> Void in
            self.viewController.performSegue(withIdentifier: "advWebView", sender: params)
        }
    }
    
    //let adImageRatio : CGFloat = 0.45625
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            QL2("create Live Player Cell")
            let song = getCurrentSong()
            livePlayerCell = tableView.dequeueReusableCell(withIdentifier: "livePlayerCell") as? LivePlayerCell
            livePlayerCell?.controller = viewController
            livePlayerCell?.initPalyer()
            self.playerViewController = livePlayerCell?.playerViewController

            //设置广告
            if song?.advText == "" || song?.advText == nil {
                livePlayerCell!.advTextLabel.text = "欢迎大家收听"
            } else {
                livePlayerCell!.advTextLabel.text = song?.advText
            }
            livePlayerCell!.advTextLabel.scrollDuration = 16
            livePlayerCell!.advTextLabel.restartLabel()
            
            //设置报名按钮
            let tapApplyButtonGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapApplyButtonHandler))
            livePlayerCell!.applyButton.addGestureRecognizer(tapApplyButtonGesture)
            livePlayerCell!.applyButton.isUserInteractionEnabled = true
            if (song?.hasAdvImage)! {
                livePlayerCell!.applyButton.isHidden = false
                livePlayerCell!.handImage.isHidden = false
            } else {
                livePlayerCell!.applyButton.isHidden = true
                livePlayerCell!.handImage.isHidden = true
            }

            //创建滚动广告
            scrollView?.auk.removeAll()
            livePlayerCell!.addSubview(scrollView!)
            
            //人数需要叠在广告上面
            let peopleLabel = livePlayerCell!.peopleCountLabel
            let peopleCountImage = livePlayerCell!.peopleCountImage
            let progressBar = livePlayerCell!.progressBar
            let playingLabel = livePlayerCell!.playingLabel
            let durationLabel = livePlayerCell!.durationLabel
            peopleLabel?.removeFromSuperview()
            peopleCountImage?.removeFromSuperview()
            progressBar?.removeFromSuperview()
            playingLabel?.removeFromSuperview()
            durationLabel?.removeFromSuperview()
            livePlayerCell!.addSubview(peopleLabel!)
            livePlayerCell!.addSubview(peopleCountImage!)
            livePlayerCell!.addSubview(progressBar!)
            livePlayerCell!.addSubview(playingLabel!)
            livePlayerCell!.addSubview(durationLabel!)
            scrollView!.auk.settings.pageControl.backgroundColor =  UIColor.gray.withAlphaComponent(0)
            scrollView!.auk.settings.contentMode = UIViewContentMode.scaleToFill
            
            
            if song != nil {
                advImages = song?.scrollAds
                for ad in (song?.scrollAds)! {
                    // Show remote image
                    QL1("ad.imageUrl = \(ad.imageUrl)")
                    scrollView!.auk.show(url: ad.imageUrl)
                }
            }
            
            var scrollRate : Int = 5
            if (song?.advScrollRate)! > 0 {
                scrollRate = (song?.advScrollRate)!
            }
            
            scrollView!.auk.startAutoScroll(delaySeconds: Double(scrollRate))
            return livePlayerCell!
        case 1:
            return getCommentCell(tableView: tableView, row: indexPath.row)
            
        default:
            return getCommentCell(tableView: tableView, row: indexPath.row)
        }
    }
    
    private func getCommentCell(tableView: UITableView, row: Int) -> UITableViewCell {
        let rowCount = (comments?.count)!

        if rowCount == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noCommentCell")
            return cell!
        } else {
            return getCommonCell(tableView: tableView, row: row)
        }

    }
    
    
    private func getCommonCell(tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
        let comment = comments![row]
        cell.userIdLabel.text = comment.nickName
        cell.timeLabel.text = comment.time
        cell.contentLabel.text = comment.content.emojiUnescapedString
        
        var frame = cell.contentLabel.frame;
        cell.contentLabel.numberOfLines = 0
        cell.contentLabel.sizeToFit()
        frame.size.height = cell.contentLabel.frame.size.height;
        cell.contentLabel.frame = frame;
        
        
        if comment.isManager {
            cell.userImage.image = UIImage(named: "user2_0")
            cell.userIdLabel.textColor = UIColor(red: 0xF2/255, green: 0x61/255, blue: 0, alpha: 0.9)
        } else {
            cell.userImage.image = UIImage(named: "user2_1")
            cell.userIdLabel.textColor = UIColor.lightGray

        }
        
        return cell
        
    }
    
    
    private func getPlayerAdvHeight() -> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return screenWidth * 0.5 + 8
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return getPlayerAdvHeight() + 77
        case 1:
            return getCommentCellHeight(tableView: tableView, row: indexPath.row)
        default:
            return getCommentCellHeight(tableView: tableView, row: indexPath.row)
        }
    }
    
    private func getCommentCellHeight(tableView: UITableView, row: Int) -> CGFloat {
        let rowCount = (comments?.count)!

        if rowCount == 0 { //没有点评的情况
            return 70
        }  else {   //评论行
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        switch section {
        case 0:
            let cell = tableView.cellForRow(at: indexPath as IndexPath)
            cell?.selectionStyle = .none
            break;
        default:
            break
        }
    }
    
    override func reload() {
        let audioPlayer = Utils.getAudioPlayer()
        if audioPlayer.currentItem != nil {
            let item = audioPlayer.currentItem as! MyAudioItem
            
            let song = item.song
            QL1("reload: song.id = \(song?.id), song.name = \(song?.name)")
            viewController.commentController.song = song
            
            playerViewController?.loadArtImage()
            
            //update comments
            let request = GetSongLiveCommentsRequest(song: song!, lastId: "-1")
            BasicService().sendRequest(url: ServiceConfiguration.GET_SONG_LIVE_COMMENTS,
                                       request: request) {
                                        (resp: GetSongLiveCommentsResponse) -> Void in
                                        DispatchQueue.main.async() {
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
                                            self.viewController.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: .none)
                                            
                                        }
            }
        }
    }
    

    
    
}
