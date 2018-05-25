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
    var loading = LoadingOverlay()
    var isDisapeared = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        addPlayingButton(button: playingButton)
        
        buyPayCourseDelegate = ConfirmDelegate2(controller: self)
        tableView.dataSource = self
        tableView.delegate = self
        
        
       
        setTitle()
        
        let loginUser = loginUserStore.getLoginUser()!
        let purchaseRecord = purchaseRecordStore.getNotNotifyRecord(userid: loginUser.userName!)
        if courseType == CourseType.PayCourse && purchaseRecord != nil {
            let request = NotifyIAPSuccessRequest()
            request.payTime = purchaseRecord?.payTime!
            request.productId = purchaseRecord?.productId!
            request.sign = Utils.createIPANotifySign(request: request)
            BasicService().sendRequest(url: ServiceConfiguration.NOTIFY_IAP_SUCCESS, request: request) {
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
        pagableController.loadMore()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            //tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)//导航栏如果使用系统原生半透明的，top设置为64
            //tableView.scrollIndicatorInsets = tableView.contentInset
            tableView.contentInset = UIEdgeInsetsMake(22, 0, 49, 0)
            tableView.estimatedRowHeight = 0
            UITableView.appearance().estimatedRowHeight = 0
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updatePlayingButton(button: playingButton)
        isDisapeared = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isDisapeared = true
    }
    
    private func setTitle() {
        self.title = courseType.name
    }
    
    //PageableControllerDelegate
    func searchHandler(respHandler: @escaping ((_ resp: ServerResponse) -> Void)) {
        
        
        let request = GetAlbumsRequest(code: "Live_Vip_Agent")
        request.pageNo = pagableController.page
        //重新设置albumDataArray
        albumDataArray = [Int]()
        BasicService().sendRequest(url: ServiceConfiguration.GET_ALBUMS, request: request,
                                   completion: respHandler as ((_ resp: GetAlbumsResponse) -> Void))
        
    }
    
    override func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        super.audioPlayer(audioPlayer, didChangeStateFrom: from, to: state)
        updatePlayingButton(button: playingButton)
    }
    
    //开始上拉到特定位置后改变列表底部的提示
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        pagableController.scrollViewDidScroll(scrollView: scrollView)
    }
    
    
    var albumDataArray = [Int]()
    
    
}

extension AlbumListController {
    
    private func makeAlbumDataArray() {
        if pagableController.data.count == 0 {
            return
        }
        let freeAlbums = pagableController.data.filter() {
            album -> Bool in
            if album.courseType.code == CourseType.LiveCourse.code {
                return true
            }
            return false
        }
        albumDataArray.append(freeAlbums.count)
       
        let paidCount = pagableController.data.count - agentAlbumCount - freeAlbumCount
        if paidCount > 0 {
            albumDataArray.append(paidCount)
        }
        
        if agentAlbumCount > 0 {
            albumDataArray.append(agentAlbumCount)
        }
        
    }
    
    func getCount(section: Int) -> Int {
        if albumDataArray.count == 0 {
            makeAlbumDataArray()
        }
        if pagableController.data.count == 0 {
            
            return 0
        }
        return albumDataArray[section]
    }
    
    var freeAlbumCount:Int {
        get {
            if pagableController.data.count == 0 {
                return 0
            }
            let freeAlbums = pagableController.data.filter() {
                album -> Bool in
                if album.courseType.code == CourseType.LiveCourse.code {
                    return true
                }
                return false
            }
            return freeAlbums.count
        }
    }
    
    var paidAlbumCount: Int {
        get {
            if pagableController.data.count == 0 {
                return 0
            }
            return pagableController.data.count - agentAlbumCount - freeAlbumCount
        }
    }
    
    var agentAlbumCount: Int {
        get {
            if pagableController.data.count == 0 {
                return 0
            }
            let agentAlubms = pagableController.data.filter() {
                album -> Bool in
                if album.isAgent {
                    return true
                }
                return false
            }
            return agentAlubms.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if pagableController.data.count == 0 {
            return 1
        }
        if  pagableController.data.count > 0 {
            makeAlbumDataArray()
        }
        return albumDataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCount(section: section)
    }
    
    private func getAlbum(indexPath: NSIndexPath) -> Album {
        let section = indexPath.section
        var album: Album!
        if section == 0 {
            album = pagableController.data[indexPath.row]
        } else if section == 1 {
            album = pagableController.data[freeAlbumCount + indexPath.row]
        } else {
            album = pagableController.data[freeAlbumCount + paidAlbumCount + indexPath.row]
        }
        return album
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = getAlbum(indexPath: indexPath as NSIndexPath)
        
        if album.isLive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "liveAlbumCell") as! LiveAlbumCell
            cell.nameLabel.text = album.name
            
            cell.listenPeopleLabel.text = album.listenCount
            if album.hasImage  {
                cell.albumImage.kf.setImage(with: URL(string: album.image)!)
            }
            if album.playing {
                cell.playingLabel.isHidden = false
            } else {
                cell.playingLabel.isHidden = true
            }
            
            if album.hasPlayTimeDesc {
                cell.descLabel.textColor = UIColor.red
                cell.descLabel.text = album.playTimeDesc
            } else {
               cell.descLabel.textColor = UIColor.lightGray
                cell.descLabel.text = album.desc
            }
            
            if album.isReady {
                cell.userIcon.image = UIImage(named: "user1_0")
            } else {
                cell.userIcon.image = UIImage(named: "user1_1")
            }
            return cell

            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell") as! AlbumCell
            cell.nameLabel.text = album.name
            cell.authorLabel.text = album.author
            
            cell.listenCountAndCountLabel.text = "\(album.listenCount), \(album.count)集"
            if album.hasImage  {
                cell.albumImage.kf.setImage(with: URL(string: album.image)!)
            }            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if pagableController.data.count == 0 {
            return 1
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if pagableController.data.count == 0 {
            return 18
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        QL1("section: \(section), row: \(row)")
        
        let album = getAlbum(indexPath: indexPath as NSIndexPath)
        if !album.isReady {
            self.displayMessage(message: "该课程未上线，敬请期待！")
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
            return
        }
        
        loading.showOverlay(view: self.view)
        
        let request = GetAlbumSongsRequest(album: album)
        request.pageSize = 200
        BasicService().sendRequest(url: ServiceConfiguration.GET_ALBUM_SONGS, request: request) {
            (resp: GetAlbumSongsResponse) -> Void in
            DispatchQueue.main.async() {
                //self.loadingOverlay.hideOverlayView()
                self.loading.hideOverlayView()
                if resp.status == ServerResponseStatus.TokenInvalid.rawValue {
                    self.displayMessage(message: "请重新登录")
                    tableView.deselectRow(at: indexPath as IndexPath, animated: false)
                    return
                }
                
                
                
                //目前这个逻辑之针对VIP课程权限够的情况
                if resp.status == ServerResponseStatus.NoEnoughAuthority.rawValue {
                    self.displayVipBuyMessage(message: resp.errorMessage!, delegate: self.buyPayCourseDelegate!)
                    tableView.deselectRow(at: indexPath as IndexPath, animated: false)
                    return
                }
                
                if self.isDisapeared {
                    return
                }
                
                if resp.status != 0 {
                    //print(resp.errorMessage)
                    self.displayMessage(message: resp.errorMessage!)
                    tableView.deselectRow(at: indexPath as IndexPath, animated: false)
                    return
                } else {
                    let songs = resp.resultSet
                    
                    if songs.count == 0 {
                        self.displayMessage(message: "敬请期待")
                        tableView.deselectRow(at: indexPath as IndexPath as IndexPath, animated: false)
                        return
                    }
                    
                    if songs.count == 1 {
                        self.performSegue(withIdentifier: "songSegue1", sender: songs)
                        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
                        return
                    }
                    
                    self.performSegue(withIdentifier: "albumDetailSegue", sender: songs)
                    tableView.deselectRow(at: indexPath as IndexPath as IndexPath, animated: false)
                }
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if pagableController.data.count == 0 {
            return nil
        }
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "albumHeaderCell") as! AlbumHeaderCell
        headerCell.isUserInteractionEnabled = false
        
        switch (section) {
        case 1:
            headerCell.titleLabel.text = "会员专享课程";
        case 2:
            headerCell.titleLabel.text = "代理商课程";
        default:
            headerCell.titleLabel.text = "每日课堂";
        }
        
        return headerCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "albumDetailSegue" {
            let dest = segue.destination as! AlbumDetailController
            let row = (tableView.indexPathForSelectedRow?.row)!
            let songs = sender as! [Song]
            dest.songs = songs
            dest.album = pagableController.data[row]
            
            
        } else if segue.identifier == "buyVipSegue" {
            let dest = segue.destination as! WebPageViewController
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
                var url = URL(string: ServiceConfiguration.GetSongUrl(urlSuffix: songItem.url))
                if songItem.album.courseType == CourseType.LiveCourse {
                    url = URL(string: songItem.url)
                }
                let audioItem = MyAudioItem(song: songItem, highQualitySoundURL: url)
                //(audioItem as! MyAudioItem).song = item
            
                audioItems.append(audioItem!)
            }
            
            audioPlayer.delegate = nil
            audioPlayer.play(items: audioItems, startAtIndex: 0)
            
        }

        
    }


}

class ConfirmDelegate2 : NSObject, UIAlertViewDelegate {
    var controller : UIViewController
    init(controller: UIViewController) {
        self.controller = controller
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            controller.performSegue(withIdentifier: "buyVipSegue", sender: nil)
            break
        case 1:
            break
        default:
            break
        }
        
    }
    
}
