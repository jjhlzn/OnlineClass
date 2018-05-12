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
    var ads = [Advertise]()
    var keyValueStore = KeyValueStore()
    var freshHeaderAdvTimer: Timer!
    var footerAdvs = [FooterAdv]()
    var headerAdv: HeaderAdv?
    var courseNotifies = [String]()
    
    var loading = LoadingOverlay()
    
    var refreshControl:UIRefreshControl!
    var refreshing = false
    var imageView: GIFImageView!
    
    var buyPayCourseDelegate: ConfirmDelegate2!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            //tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)//导航栏如果使用系统原生半透明的，top设置为64
            //tableView.scrollIndicatorInsets = tableView.contentInset
            if UIDevice().isX() {
                tableView.contentInset = UIEdgeInsetsMake(22, 0, 49, 0)
            } else {
                tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
            }
            tableView.estimatedRowHeight = 0
            UITableView.appearance().estimatedRowHeight = 0
        }
        
        tableView.separatorStyle = .none
        
        tableView.dataSource = self
        tableView.delegate = self

        
        buyPayCourseDelegate = ConfirmDelegate2(controller: self)
        
        let screenHeight = UIScreen.main.bounds.height
        var maxRows = 3
        if screenHeight < 568 {  //568
            maxRows = 2
        }
        extendFunctionMananger = ExtendFunctionMananger(controller: self, isNeedMore:  true, showMaxRows: maxRows)
        //addPlayingButton(button: playingButton)
        loadFunctionInfos()
        
        //下拉刷新设置
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        refreshing = false
        
        self.imageView = GIFImageView(frame: CGRect(x: -10, y: 0, width: 36, height: 80))
        self.imageView.backgroundColor = nil
        self.imageView.animate(withGIFNamed: "demo") {
            print("It's animating!")
        }
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMusicBtnHandler(sender:))))
        //imageView.stopAnimatingGIF()
        let button2 = UIBarButtonItem(customView: self.imageView)
        //let button1 = UIBarButtonItem(image: UIImage(named: "imagename"), style: .plain, target: self, action: Selector("action")) // action:#selector(Class.MethodName) for swift 3
        //self.navigationItem.rightBarButtonItems?.append(button2)
        self.navigationItem.rightBarButtonItem  = button2
        
        let searchLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        searchLabel.layer.masksToBounds = true
        searchLabel.layer.cornerRadius = 15
        searchLabel.backgroundColor =  UIColor(white: 0.9, alpha: 0.8)
        searchLabel.text = "融资、信用卡、关键词"
        searchLabel.textColor =  UIColor.lightGray
        searchLabel.font = searchLabel.font.withSize(13)
        
        searchLabel.textAlignment = .center
        
        self.navigationItem.titleView = searchLabel
     
    }
    
    @objc func tapMusicBtnHandler(sender: UITapGestureRecognizer? = nil) {
        if self.imageView.isAnimatingGIF {
            self.imageView.stopAnimatingGIF()
          
        } else {
            self.imageView.startAnimatingGIF()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //updatePlayingButton(button: playingButton)
        loadHeadAds()
        //loadFooterAdvs()
        //loadCourseNotify()
        
        createTimer()
      
        //let button1 = UIBarButtonItem(image: UIImage(named: "imagename"), style: .plain, target: self, action: Selector("action")) // action:#selector(Class.MethodName) for swift 3
        //self.navigationItem.rightBarButtonItems?.append(button2)
       
        
        self.imageView = GIFImageView(frame: CGRect(x: -10, y: 0, width: 36, height: 80))
        self.imageView.backgroundColor = nil
        self.imageView.animate(withGIFNamed: "demo") {
            print("It's animating!")
        }
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMusicBtnHandler(sender:))))
        //imageView.stopAnimatingGIF()
        let button2 = UIBarButtonItem(customView: self.imageView)
        //let button1 = UIBarButtonItem(image: UIImage(named: "imagename"), style: .plain, target: self, action: Selector("action")) // action:#selector(Class.MethodName) for swift 3
        //self.navigationItem.rightBarButtonItems?.append(button2)
        self.navigationItem.rightBarButtonItem  = button2
        
        let searchLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        searchLabel.layer.masksToBounds = true
        searchLabel.layer.cornerRadius = 15
        searchLabel.backgroundColor =  UIColor(white: 0.9, alpha: 0.8)
        searchLabel.text = "融资、信用卡、关键词"
        searchLabel.textColor =  UIColor.lightGray
        searchLabel.font = searchLabel.font.withSize(13)
        
        searchLabel.textAlignment = .center
        
        self.navigationItem.titleView = searchLabel
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        freshHeaderAdvTimer.invalidate()
        imageView.prepareForReuse()
        self.navigationItem.rightBarButtonItem  = nil
    }
    
    private func createTimer() {
        freshHeaderAdvTimer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                                   selector: #selector(loadHeadAds), userInfo: nil, repeats: true)
    }

    @objc func loadHeadAds() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_MAIN_PAGE_ADS, request: GetMainPageAdsRequest()) {
            (resp: GetMainPageAdsResponse) -> Void in
            if self.refreshing {
                self.refreshControl.endRefreshing()
            }
            self.refreshing = false
            
            let ads = resp.ads
            let headerCell = self.tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! HeaderAdvCell
            headerCell.ads = ads
            headerCell.update()
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
        }
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
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
        loadFunctionInfos()
    }
    
    var footerImageInterWidth = 2
}


extension CourseMainPageViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getRowCount()
    }
    
    private func getRowCount() -> Int {
        return 1 + extendFunctionMananger.getRowCount() + 1 + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainpageHeaderAdvCell") as! HeaderAdvCell
            cell.initialize()
            return cell
        } else if row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell")
            //courseNotifies = [String]()
            return cell!
        } else if row == 2 || row == 3  {
            let cell = extendFunctionMananger.getFunctionCell(tableView: tableView, row: row - 2)
            return cell
        } else if row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell")
            return cell!
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
        } else {
            return extendFunctionMananger.cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        return nil
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
            if headerAdv != nil {
                if (headerAdv?.type)! == HeaderAdv.Type_Song {
                    loading.showOverlay(view: view)
                    let request = GetSongInfoRequest()
                    let album = Album()
                    album.courseType = CourseType.LiveCourse
                    let reqSong = Song()
                    reqSong.album = album
                    reqSong.id = (headerAdv?.songId)!
                    request.song = reqSong
                    BasicService().sendRequest(url: ServiceConfiguration.GET_SONG_INFO, request: request) {
                        (resp : GetSongInfoResponse) -> Void in
                        self.loading.hideOverlayView()
                        if resp.status == ServerResponseStatus.NoEnoughAuthority.rawValue {
                            self.displayVipBuyMessage(message: resp.errorMessage!, delegate: self.buyPayCourseDelegate!)
                            return
                        }
                        
                        if resp.isFail {
                            self.displayMessage(message: resp.errorMessage!)
                            return
                        }
                        
                        let song = resp.song
                        if song == nil {
                            return
                        }
                        
                        let audioPlayer = self.getAudioPlayer()
                        //如果当前歌曲已经在播放，就什么都不需要做
                        if audioPlayer.currentItem != nil {
                            if song?.id == (audioPlayer.currentItem! as! MyAudioItem).song.id {
                                self.performSegue(withIdentifier: "songSegue", sender: false)
                                return
                            }
                        }
                        
                        var audioItems = [AudioItem]()
                        let songs = [song]
                        for songItem in songs {
                            var url = URL(string: (songItem?.url)!)
                            let audioItem = MyAudioItem(song: songItem!, highQualitySoundURL: url)
                            audioItems.append(audioItem!)
                        }
                        
                        audioPlayer.delegate = nil
                        //TODO: play
                        //audioPlayer.playItems(audioItems, startAtIndex: 0)
                        self.performSegue(withIdentifier: "songSegue", sender: false)
                        
                    }
                } else {
                    performSegue(withIdentifier: "beforeCourseSegue", sender: CourseType.LiveCourse)
                    
                }
            }
        }
    }
    
    func tapAdImageHandler(sender: UITapGestureRecognizer? = nil) {
        let scrollView = sender?.view as! UIScrollView
        let index = scrollView.auk.currentPageIndex
        if index != nil {
            let params : [String: String] = ["url": ads[index!].clickUrl, "title": ads[index!].title]
            performSegue(withIdentifier: "loadWebPageSegue", sender: params)
        }
    }
    
    var footerImageWidth:CGFloat {
        get {
            let screenWidth = UIScreen.main.bounds.width;
            let width = (screenWidth - CGFloat(footerImageInterWidth * 3)) / 4
            return width
        }
    }
    
    var footerImageHeight:CGFloat {
        get {
            return footerImageWidth * 1418 / 1380
        }
    }
    
    @objc func footerAdvImageHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        if self.footerAdvs.count != 4 {
            return
        }
        let footerAdv = self.footerAdvs[index!]
        let params : [String: String] = ["url": footerAdv.url, "title": footerAdv.title]
        if footerAdv.url == "" {
            QL3("footer adv is empty, no jump to other page")
            return
        }
        
        //如果是快速下款，通过使用外部浏览器打开
        if footerAdv.title == "快速下卡" {
            UIApplication.shared.openURL(NSURL(string: footerAdv.url)! as URL)
        } else {
            performSegue(withIdentifier: "loadWebPageSegue", sender: params)
        }
    }
    
    private func makeImage(index: Int, adv: FooterAdv) -> UIImageView {
        let x = CGFloat(index) * footerImageWidth + CGFloat(index * footerImageInterWidth);
        var y =  computeAdCellHeight() - footerImageHeight
        
        if y < 0 {
            y = 0
        }

        let imageView = UIImageView(frame: CGRect(x: x, y: y, width: footerImageWidth, height: footerImageHeight))
        imageView.tag = index
        if adv.imageUrl != "" {
            if let imageUrl = URL(string: adv.imageUrl) {
                //QL1("imageUrl: \(adv.imageUrl)")
                //imageView.kf_setImageWithURL(imageUrl)
                imageView.kf.setImage(with: imageUrl)
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(footerAdvImageHandler) ))
                imageView.isUserInteractionEnabled = true

            }
        } else {
            imageView.image = UIImage(named: "footer_ditu")
        }
        
        return imageView
    }
    
    private func computeAdCellHeight() -> CGFloat {
        let section1Height = getHeaderAdvHeight()
        let section2Height = CGFloat(extendFunctionMananger.getRowCount()) * extendFunctionMananger.cellHeight
        let total = section1Height + section2Height + 18 + 3 + 65 + 49 - 5
        var height = UIScreen.main.bounds.height - CGFloat(total)
        
        if height < footerImageHeight  {
            height = footerImageHeight
        }
        return height
    }
    
    
    private func getHeaderAdvHeight() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth * 122 / 320 + 10
        //return 172
    }

}
