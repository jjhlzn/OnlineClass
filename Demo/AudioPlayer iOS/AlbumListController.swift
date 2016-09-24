//
//  AlbumListController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer
import QorumLogs

class AlbumListController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate, PagableControllerDelegate {
    
    @IBOutlet weak var playingButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    var pagableController = PagableController<Album>()
    var courseType : CourseType = CourseType.LiveCourse
    var purchaseRecordStore = PurchaseRecordStore()
    var loginUserStore = LoginUserStore()
    var loadingOverlay = LoadingOverlay()
    var buyPayCourseDelegate : ConfirmDelegate2?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        addPlayingButton(playingButton)
        
        buyPayCourseDelegate = ConfirmDelegate2(controller: self)
        tableView.dataSource = self
        tableView.delegate = self
        
        setTitle()
        
        let loginUser = loginUserStore.getLoginUser()!
        let purchaseRecord = purchaseRecordStore.getNotNotifyRecord(loginUser.userName!)
        if courseType == CourseType.PayCourse && purchaseRecord != nil {
            let request = NotifyIAPSuccessRequest()
            request.payTime = purchaseRecord?.payTime!
            request.productId = purchaseRecord?.productId!
            request.sign = Utils.createIPANotifySign(request)
            BasicService().sendRequest(ServiceConfiguration.NOTIFY_IAP_SUCCESS, request: request) {
                (resp: NotifyIAPSuccessResponse) -> Void in
                if resp.status != ServerResponseStatus.Success.rawValue {
                    QL4("resp.status = \(resp.status), message = \(resp.errorMessage)")
                    return;
                }
                if purchaseRecord != nil {
                    purchaseRecord!.isnotify = true
                    self.purchaseRecordStore.update()
                }
            }
        }
        
        //初始化PagableController
        pagableController.viewController = self
        pagableController.delegate = self
        pagableController.tableView = tableView
        pagableController.isNeedRefresh = true
        pagableController.initController()
        pagableController.isShowLoadCompleteText = false
        //pagableController.loadMore()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        updatePlayingButton(playingButton)
    }
    
    //TODO: 这里的名称不能写死
    private func setTitle() {
        switch courseType.code {
        case "Live":
            self.title = "直播课程"
            break
        case "Vip":
            self.title = "会员专享课堂"
            break
        default:
            break
        }
    }
    
    //PageableControllerDelegate
    func searchHandler(respHandler: ((resp: ServerResponse) -> Void)) {
        let request = GetAlbumsRequest(courseType: courseType)
        request.pageNo = pagableController.page
        BasicService().sendRequest(ServiceConfiguration.GET_ALBUMS, request: request,
                                   completion: respHandler as ((resp: GetAlbumsResponse) -> Void))

    }
    
    
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        super.audioPlayer(audioPlayer, didChangeStateFrom: from, toState: to)
        updatePlayingButton(playingButton)
    }
    
    //开始上拉到特定位置后改变列表底部的提示
    func scrollViewDidScroll(scrollView: UIScrollView){
        pagableController.scrollViewDidScroll(scrollView)
    }

}

extension AlbumListController {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pagableController.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let album = pagableController.data[indexPath.row]
        
        if album.isLive {
            let cell = tableView.dequeueReusableCellWithIdentifier("liveAlbumCell") as! LiveAlbumCell
            cell.nameLabel.text = album.name
            cell.descLabel.text = album.desc
            cell.listenPeopleLabel.text = album.listenCount
            if album.hasImage  {
                cell.albumImage.kf_setImageWithURL(NSURL(string: album.image)!)
            }
            if album.playing {
                cell.playingLabel.hidden = false
            }
            return cell

            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("albumCell") as! AlbumCell
            cell.nameLabel.text = album.name
            cell.authorLabel.text = album.author
            
            cell.listenCountAndCountLabel.text = "\(album.listenCount), \(album.count)集"
            if album.hasImage  {
                cell.albumImage.kf_setImageWithURL(NSURL(string: album.image)!)
            }            
            return cell

        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let album = pagableController.data[indexPath.row]
        if !album.isReady {
            self.displayMessage("该课程未上线，敬请期待！")
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            return
        }
        
        let request = GetAlbumSongsRequest(album: album)
        request.pageSize = 200
        BasicService().sendRequest(ServiceConfiguration.GET_ALBUM_SONGS, request: request) {
            (resp: GetAlbumSongsResponse) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.loadingOverlay.hideOverlayView()
                if resp.status == ServerResponseStatus.TokenInvalid.rawValue {
                    self.displayMessage("请重新登录")
                    tableView.deselectRowAtIndexPath(indexPath, animated: false)
                    return
                }
                
                //目前这个逻辑之针对VIP课程权限够的情况
                if resp.status == ServerResponseStatus.NoEnoughAuthority.rawValue {
                    self.displayVipBuyMessage(resp.errorMessage!, delegate: self.buyPayCourseDelegate!)
                    tableView.deselectRowAtIndexPath(indexPath, animated: false)
                    return
                }
                
                if resp.status != 0 {
                    print(resp.errorMessage)
                    self.displayMessage(resp.errorMessage!)
                    tableView.deselectRowAtIndexPath(indexPath, animated: false)
                    return
                } else {
                    let songs = resp.resultSet
                    
                    if songs.count == 0 {
                        self.displayMessage("敬请期待")
                        tableView.deselectRowAtIndexPath(indexPath, animated: false)
                        return
                    }
                    
                    if songs.count == 1 {
                        self.performSegueWithIdentifier("songSegue1", sender: songs)
                        tableView.deselectRowAtIndexPath(indexPath, animated: false)
                        return
                    }
                    
                    self.performSegueWithIdentifier("albumDetailSegue", sender: songs)
                    tableView.deselectRowAtIndexPath(indexPath, animated: false)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "albumDetailSegue" {
            let dest = segue.destinationViewController as! AlbumDetailController
            let row = (tableView.indexPathForSelectedRow?.row)!
            let songs = sender as! [Song]
            dest.songs = songs
            dest.album = pagableController.data[row]
            
            
        } else if segue.identifier == "bugVipSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            dest.url = NSURL(string: ServiceLinkManager.MyAgentUrl)
            dest.title = "Vip购买"
        } else if segue.identifier == "songSegue1" {
            //let dest = segue.destinationViewController as! SongViewController
            let songs = sender as! [Song]
            let song = songs[0]
            
            let audioPlayer = getAudioPlayer()
            //如果当前歌曲已经在播放，就什么都不需要做
            if audioPlayer.currentItem != nil {
                if song.id == (audioPlayer.currentItem! as! MyAudioItem).song.id {
                    return
                }
            }
            
            var audioItems = [AudioItem]()
            for songItem in songs {
                var url = NSURL(string: ServiceConfiguration.GetSongUrl(songItem.url))
                if songItem.album.courseType == CourseType.LiveCourse {
                    url = NSURL(string: songItem.url)
                }
                let audioItem = MyAudioItem(song: songItem, highQualitySoundURL: url)
                //(audioItem as! MyAudioItem).song = item
                audioItems.append(audioItem!)
            }
            
            audioPlayer.delegate = nil
            audioPlayer.playItems(audioItems, startAtIndex: 0)
            
        }

        
    }


}

class ConfirmDelegate2 : NSObject, UIAlertViewDelegate {
    var controller : UIViewController
    init(controller: UIViewController) {
        self.controller = controller
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            controller.performSegueWithIdentifier("bugVipSegue", sender: nil)
            break
        case 1:
            break
        default:
            break
        }
        
    }
    
}