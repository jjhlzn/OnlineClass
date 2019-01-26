//
//  CourseListVC.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/15.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs
import KDEAudioPlayer
import MJRefresh

class CourseListVC: BaseUIViewController, UITableViewDataSource, UITableViewDelegate, PagableControllerDelegate {

    var pagableController = PagableController<Album>()
    var courseType : CourseType = CourseType.LiveCourse
    var purchaseRecordStore = PurchaseRecordStore()
    var loginUserStore = LoginUserStore()
    var loadingOverlay = LoadingOverlay()
    var buyPayCourseDelegate : ConfirmDelegate2?
    var loading = LoadingOverlay()
    var isDisapeared = false
    
    var courses = [Album]()

    @IBOutlet weak var tableView: UITableView!
    
    var navigationManager : NavigationBarManager!
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationManager = NavigationBarManager(self)
        
        super.viewDidLoad()
        print("viewDidLoad")
        //addPlayingButton(button: playingButton)
        
        buyPayCourseDelegate = ConfirmDelegate2(controller: self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        //setTitle()
        
        let loginUser = loginUserStore.getLoginUser()!
        let purchaseRecord = purchaseRecordStore.getNotNotifyRecord(userid: loginUser.userName!)
        if courseType == CourseType.PayCourse && purchaseRecord != nil {
            let request = NotifyIAPSuccessRequest()
            request.payTime = purchaseRecord?.payTime!
            request.productId = purchaseRecord?.productId!
            request.sign = Utils.createIPANotifySign(request: request)
            _ = BasicService().sendRequest(url: ServiceConfiguration.NOTIFY_IAP_SUCCESS, request: request) {
                (resp: NotifyIAPSuccessResponse) -> Void in
                if resp.status != ServerResponseStatus.Success.rawValue {
                    QL4("resp.status = \(resp.status), message = \(String(describing: resp.errorMessage))")
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
        
        Utils.setNavigationBarAndTableView(self, tableView: tableView)
        
    }
    
    func setNavigationBar() {
        self.navigationItem.rightBarButtonItems = []
        navigationManager.setMusicButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDisapeared = false
        setNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isDisapeared = true
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
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "loadWebPageSegue" {
            let dest = segue.destination as! WebPageViewController
            
            let params = sender as! [String: String]
            dest.url = NSURL(string: params["url"]!)
            
            dest.title = params["title"]
        } else if segue.identifier == "buyVipSegue" {
            let args = sender as! [String:String]
            let dest = segue.destination as! WebPageViewController
            let url = "\(ServiceLinkManager.BuyProductUrl)?type=course&id=\(args["courseId"]!)"
            dest.url = NSURL(string: url)
            dest.title = "确认支付"
        } else if segue.identifier == "newPlayerSegue" {
            let song = sender as! Song
            let audioPlayer = getAudioPlayer()
            //如果当前歌曲已经在播放，就什么都不需要做
            if audioPlayer.currentItem != nil {
                if song.id == (audioPlayer.currentItem! as! MyAudioItem).song.id {
                    return
                }
            }
            
            var audioItems = [AudioItem]()
            let   url = URL(string: song.url)
            
            let audioItem = MyAudioItem(song: song, highQualitySoundURL: url)
            //(audioItem as! MyAudioItem).song = item
            
            audioItems.append(audioItem!)
            // }
            
            audioPlayer.delegate = nil
            audioPlayer.play(items: audioItems, startAtIndex: 0)
        }
    }
    
    var albumDataArray = [Int]()

}

extension CourseListVC {
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
        let row = indexPath.row
        var album: Album!
        if section == 0 {
            album = pagableController.data[row]
        } else if section == 1 {
            album = pagableController.data[freeAlbumCount + row]
        } else {
            let index = freeAlbumCount + paidAlbumCount + row
            QL1("freeAlbumCount = \(freeAlbumCount), paidAlbumCount = \(paidAlbumCount), index = \(index)")
            album = pagableController.data[index]
        }
        return album
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = getAlbum(indexPath: indexPath as NSIndexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newAlbumCell") as! NewAlbumCell
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.autoresizesSubviews = false
        cell.setNeedsUpdateConstraints()
        cell.course = album
        cell.update()
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if pagableController.data.count == 0 {
            return nil
        }
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "courseHeaderCell") as! NewCourseHeaderCell
        headerCell.isUserInteractionEnabled = false
        //headerCell.backgroundColor = UIColor.red
        
        switch (section) {
        case 1:
            headerCell.titleLabel.text = "VIP学习";
        case 2:
            headerCell.titleLabel.text = "推广人学习";
        default:
            headerCell.titleLabel.text = "每日学习";
        }
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 204
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if pagableController.data.count == 0 {
            return 1
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if pagableController.data.count == 0 {
            return 18
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        let row = indexPath.row
        let section = indexPath.section
        let album: Album!
        if section == 0 {
            album = pagableController.data[row]
        } else if section == 1 {
            album = pagableController.data[freeAlbumCount + row]
        } else {
            let index = freeAlbumCount + paidAlbumCount + row
            QL1("freeAlbumCount = \(freeAlbumCount), paidAlbumCount = \(paidAlbumCount), index = \(index)")
            album = pagableController.data[index]
        }
        //performSegue(withIdentifier: "newPlayerSegue", sender: nil)
        if !album.isReady {
            self.displayMessage(message: "该课程未上线，敬请期待！")
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
            return
        }
        
        loading.showOverlay(view: self.view)
        
        let req = GetAlbumSongsRequest(album: album)
        BasicService().sendRequest(url: ServiceConfiguration.GET_ALBUM_SONGS, request: req) {
            (resp: GetAlbumSongsResponse) -> Void in
            
            self.loading.hideOverlayView()
            if resp.status == ServerResponseStatus.TokenInvalid.rawValue {
                self.displayMessage(message: "请重新登录")
                tableView.deselectRow(at: indexPath as IndexPath, animated: false)
                return
            }
            
            
            //目前这个逻辑之针对VIP课程权限够的情况
            if resp.status == ServerResponseStatus.NoEnoughAuthority.rawValue {
                self.buyPayCourseDelegate?.courseId = album.id
                self.displayVipBuyMessage(message: resp.errorMessage!, delegate: self.buyPayCourseDelegate!)
                tableView.deselectRow(at: indexPath as IndexPath, animated: false)
                return
            }
            
            if self.isDisapeared {
                return
            }
            
            let songs = resp.resultSet
            if (songs.count == 0) {
                self.displayMessage(message: "获取课程失败")
                return
            }
            
            let song = songs[0]
            DispatchQueue.main.async { () -> Void in
                self.performSegue(withIdentifier: "newPlayerSegue", sender: song)
            }
        }
    }
    
    func loadAlbumSongs(_ album: Album) {
        let req = GetAlbumSongsRequest(album: album)
        BasicService().sendRequest(url: ServiceConfiguration.GET_ALBUM_SONGS, request: req) {
            (resp: GetAlbumSongsResponse) -> Void in
            
            let songs = resp.resultSet
            if (songs.count == 0) {
                self.displayMessage(message: "获取课程失败")
                return
            }
            
            let song = songs[0]
            DispatchQueue.main.async { () -> Void in
                self.performSegue(withIdentifier: "newPlayerSegue", sender: song)
            }
        }
    }
}
