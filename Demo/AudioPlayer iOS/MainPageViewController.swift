//
//  CourseMainPageViewController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer
import QorumLogs
import Auk
import MarqueeLabel
import Gifu

class CourseMainPageViewController: BaseUIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    //@IBOutlet weak var playingButton: UIButton!
    var extendFunctionMananger : ExtendFunctionMananger!
    var extendFunctionStore = ExtendFunctionStore.instance
    var extendFunctionImageStore = ExtendFunctionImageStore()

    var keyValueStore = KeyValueStore()

    var loading = LoadingOverlay()
    var refreshControl:UIRefreshControl!
    var refreshing = false
    
    var toutiao = Toutiao()
    var ads = [Advertise]()
    var zhuanLans = [ZhuanLan]()
    var courses = [Album]()
    
    var buyPayCourseDelegate: ConfirmDelegate2!
    var isDisapeared = false
    var navigationManager : NavigationBarManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationManager = NavigationBarManager(self)
        Utils.setNavigationBarAndTableView(self, tableView: tableView)
        
        tableView.separatorStyle = .none
        
        tableView.dataSource = self
        tableView.delegate = self

        
        buyPayCourseDelegate = ConfirmDelegate2(controller: self)
        
        let screenHeight = UIScreen.main.bounds.height
        var maxRows = 3
        if screenHeight < 568 {  //568
            maxRows = 2
        }
        extendFunctionMananger = ExtendFunctionMananger(controller: self, isNeedMore:  false, showMaxRows: maxRows)
        //addPlayingButton(button: playingButton)
        loadFunctionInfos()
        
        //下拉刷新设置
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        refreshing = false
    }
    

    
    func setNavigationBar() {
        
        self.navigationItem.rightBarButtonItems = []
        navigationManager.setMusicButton()
        setKefuButton()
        let searchLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        searchLabel.layer.masksToBounds = true
        searchLabel.layer.cornerRadius = 15
        searchLabel.backgroundColor =  UIColor(white: 0.9, alpha: 0.8)
        searchLabel.text = "融资、信用卡、关键词"
        searchLabel.textColor =  UIColor.lightGray
        searchLabel.font = searchLabel.font.withSize(13)
        searchLabel.textAlignment = .center
        searchLabel.isUserInteractionEnabled = true
        
        self.navigationItem.titleView = searchLabel
        let tap = UITapGestureRecognizer(target: self, action: #selector(CourseMainPageViewController.tapSearchLabel))
        searchLabel.addGestureRecognizer(tap)
    }
    
    @objc func tapSearchLabel(sender:UITapGestureRecognizer) {
        QL1("seachLabel tapped")
        performSegue(withIdentifier: "newSearchSegue", sender: nil)
    }
    
    func setKefuButton() {
        let b = UIButton(type: .custom)
        b.setImage( UIImage(named: "new_kefu"), for: .normal)
        b.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        let button = UIBarButtonItem(customView: b)
        b.addTarget(self, action: #selector(keFuPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem  = button
    }
    
    @objc func keFuPressed() {
        var sender = [String:String]()
        sender["title"] = "客服"
        sender["url"] = ServiceLinkManager.FunctionCustomerServiceUrl
        performSegue(withIdentifier: "loadWebPageSegue", sender: sender)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //updatePlayingButton(button: playingButton)
        loadHeadAds()
        loadZhuanLanAndTuijianCourses()
        loadToutiao()
        self.setNavigationBar()
        isDisapeared = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         navigationManager.setMusicBtnState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.rightBarButtonItem  = nil
        
        isDisapeared = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "beforeCourseSegue" {
            let dest = segue.destination as! AlbumListController
            
            dest.courseType = sender as! CourseType
        } 
        else if segue.identifier == "loadWebPageSegue" {
            let dest = segue.destination as! WebPageViewController
            
            let params = sender as! [String: String]
            dest.url = NSURL(string: params["url"]!)
            
            dest.title = params["title"]
        } else if segue.identifier == "buyVipSegue" {
            let dest = segue.destination as! WebPageViewController
            dest.url = NSURL(string: ServiceLinkManager.MyAgentUrl)
            dest.title = "Vip购买"
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

            var   url = URL(string: song.url)
            let audioItem = MyAudioItem(song: song, highQualitySoundURL: url)
            audioItems.append(audioItem!)

            audioPlayer.delegate = nil
            audioPlayer.play(items: audioItems, startAtIndex: 0)
        }
    }
    
    override func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        let audioItem = getAudioPlayer().currentItem
        if audioItem == nil {
            return
        }
        //updatePlayingButton(button: playingButton)
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        performSegue(withIdentifier: "searchSegue", sender: nil)
    }
    
    @objc func refresh() {
        if (refreshing) {
            refreshControl.endRefreshing()
            return
        }
        
        refreshing = true
        loadHeadAds()
        loadToutiao()
        loadFunctionInfos()
        loadZhuanLanAndTuijianCourses()
    }
    
    @IBAction func viewZhuanLanListPressed(_ sender: Any) {
        performSegue(withIdentifier: "zhuanLanListSegue", sender: nil)
    }
    
    
}


extension CourseMainPageViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count =  1 + extendFunctionMananger.getRowCount()  + 1
        count += (1 + zhuanLans.count)
        count += 1
        
        count += ( courses.count)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainpageHeaderAdvCell") as! HeaderAdvCell
            cell.controller = self
            cell.initialize()
            cell.toutiao = self.toutiao
            cell.ads = ads
            cell.update()
            return cell
        } else if row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell")
            return cell!
        } else if row == 2 || row == 3  {
            let cell = extendFunctionMananger.getFunctionCell(tableView: tableView, row: row - 2)
            return cell
        } else if row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell")
            return cell!
        } else if row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "zhuanLanHeaderCell")!
            return cell
        } else if row > 5 && row < 5 + 1 + zhuanLans.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "zhuanLanCell") as! ZhuanLanCell
            cell.zhuanLan = zhuanLans[row - 5 - 1]
            cell.update()
            return cell
        } else if row == 6 + zhuanLans.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tuijianCourseHeaderCell")!
            return cell
        } else if row >  6 + zhuanLans.count && row < 6 + zhuanLans.count + 1 + courses.count  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tuijianCourseCell") as! MainPageCourseCell
            cell.course = courses[row - 6 - zhuanLans.count - 1]
            cell.update()
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "seperatorCell")!
        }
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 0 {
            return getHeaderAdvHeight()
        } else if row == 1 {
            return 8
        } else if row == 2 || row == 3 {
            return extendFunctionMananger.cellHeight
        } else if row == 4 {
            return 8
        } else if row == 5 {
            return 40
        } else if row > 5 && row < 5 + 1 + zhuanLans.count {
            return 110
        } else if row == 6 + zhuanLans.count {
            return 40
        } else if row >  6 + zhuanLans.count && row < 6 + zhuanLans.count + 1 + courses.count  {
            return 140
        } else {
            return 8
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        let row = indexPath.row
        if row == 0 {
            
        } else if row == 1 {
           
        } else if row == 2 || row == 3 {
            
        } else if row == 4 {
          
        } else if row == 5 {
           
        } else if row > 5 && row < 5 + 1 + zhuanLans.count {
            var sender = [String:String]()
            sender["title"] = zhuanLans[row - 5 - 1].name
            sender["url"] = zhuanLans[row - 5 - 1].url
            performSegue(withIdentifier: "loadWebPageSegue", sender: sender)
            
        } else if row == 6 + zhuanLans.count {
            
        } else if row >  6 + zhuanLans.count && row < 6 + zhuanLans.count + 1 + courses.count  {
            let album = courses[row - 6 - zhuanLans.count - 1]
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
                self.performSegue(withIdentifier: "newPlayerSegue", sender: song)
            }
        }
    }
    
    private func getHeaderAdvHeight() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth * 122 / 320 + 10
        //return 172
    }

}

extension CourseMainPageViewController  {

    
    @objc func loadHeadAds() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_MAIN_PAGE_ADS, request: GetMainPageAdsRequest()) {
            (resp: GetMainPageAdsResponse) -> Void in
            if self.refreshing {
                self.refreshControl.endRefreshing()
            }
            self.refreshing = false
            
            self.ads = resp.ads
            self.tableView.reloadData()
        }
    }
    
    
    func loadFunctionInfos() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_FUNCTION_INFO, request: GetFunctionInfosRequest()) {
            (resp: GetFunctionInfosResponse) -> Void in
            if resp.status != ServerResponseStatus.Success.rawValue {
                QL4("server return error: \(resp.errorMessage!)")
                return
            }
            //更新消息
            var imageUrls = [String]()
            for function in resp.functions {
                self.extendFunctionStore.updateMessageCount(code: function.code, value: function.messageCount)
                self.extendFunctionStore.updateShow(code: function.code, value: function.isShow)
                self.extendFunctionStore.updateFunctionName(code: function.code, value: function.name)
                self.extendFunctionStore.updateImageUrl(code: function.code, value: function.imageUrl)
                if function.imageUrl != "" {
                    imageUrls.append(function.imageUrl)
                }
            }
            self.tableView.reloadData()
            self.downloadFunctionImages(imageUrls: imageUrls)
        }
        
    }
    
    func loadZhuanLanAndTuijianCourses() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_ZHUANLAN_AND_TUIJIAN_COURSES, request: GetZhuanLanAndTuijianCoursesRequest()) {
            (resp: GetZhuanLanAndTuijianCoursesResponse) -> Void in
            if self.refreshing {
                self.refreshControl.endRefreshing()
            }
            self.refreshing = false
            
            self.zhuanLans = resp.zhuanLans
            self.courses = resp.albums
            
            self.tableView.reloadData()
        }
    }
    
    func loadToutiao() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_TOUTIAO, request: GetToutiaoRequest()) {
            (resp: GetToutiaoResponse) -> Void in
            if self.refreshing {
                self.refreshControl.endRefreshing()
            }
            self.refreshing = false
            
            self.toutiao.content = resp.content
            self.toutiao.clickUrl = resp.clickUrl
            self.toutiao.title = resp.title
            
            self.tableView.reloadData()
        }
    }
    
    func downloadFunctionImages(imageUrls: [String]) {
        for imageUrl in imageUrls {
            
            let image = extendFunctionImageStore.getImage(imageUrl: imageUrl)
            if image == nil {
                let imageView = UIImageView()
                imageView.kf.setImage(with: URL(string: imageUrl)!)
                
                /*
                 imageView.kf_setImageWithURL(NSURL(string: imageUrl)!,
                 placeholderImage: nil,
                 optionsInfo: [.ForceRefresh],
                 completionHandler: { (image, error, cacheType, imageURL) -> () in
                 if image != nil {
                 self.extendFunctionImageStore.saveOrUpdate(imageUrl, image: image!)
                 self.tableView.reloadData()
                 }
                 }) */
                
            }
        }
    }
}
