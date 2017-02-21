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

class CourseMainPageViewController: BaseUIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playingButton: UIButton!
    var extendFunctionMananger : ExtendFunctionMananger!
    var extendFunctionStore = ExtendFunctionStore.instance
    var ads = [Advertise]()
    var keyValueStore = KeyValueStore()
    var freshHeaderAdvTimer: NSTimer!
    var footerAdvs = [FooterAdv]()
    var headerAdv: HeaderAdv?
    var courseNotifies = [String]()
    
    var loading = LoadingOverlay()
    
    var refreshControl:UIRefreshControl!
    var refreshing = false
    
    var buyPayCourseDelegate: ConfirmDelegate2!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        
        buyPayCourseDelegate = ConfirmDelegate2(controller: self)
        
        let screenHeight = UIScreen.mainScreen().bounds.height
        var maxRows = 3
        if screenHeight < 568 {  //568
            maxRows = 2
        }
        extendFunctionMananger = ExtendFunctionMananger(controller: self, isNeedMore:  true, showMaxRows: maxRows)
        addPlayingButton(playingButton)
        loadFunctionInfos()
        
        //下拉刷新设置
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        refreshing = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updatePlayingButton(playingButton)
        loadHeaderAdv()
        loadFooterAdvs()
        loadCourseNotify()
        
        createTimer()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        freshHeaderAdvTimer.invalidate()
    }
    
    private func createTimer() {
        freshHeaderAdvTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self,
                                                                selector: #selector(loadHeaderAdv), userInfo: nil, repeats: true)
    }
    

    func loadHeaderAdv() {
        BasicService().sendRequest(ServiceConfiguration.GET_HEADER_ADV, request: GetHeaderAdvRequest()) {
            (resp: GetHeaderAdvResponse) -> Void in
            if self.refreshing {
                self.refreshControl.endRefreshing()
            }
            self.refreshing = false
            
            if resp.status != ServerResponseStatus.Success.rawValue {
                QL4("server return error: \(resp.errorMessage!)")
                return
            }
            
            if resp.headerAdv != nil {
                let headerCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! HeaderAdvCell

                self.headerAdv = resp.headerAdv
                if let imageUrl = NSURL(string: (resp.headerAdv?.imageUrl)!) {
                    headerCell.advImage.kf_setImageWithURL(imageUrl)
                }
            }
        }
    }
    
    func loadFooterAdvs() {
        BasicService().sendRequest(ServiceConfiguration.GET_FOOTER_ADV, request: GetFooterAdvsRequest() ) {
            (resp: GetFooterAdvsResponse) -> Void in
            if resp.status != ServerResponseStatus.Success.rawValue {
                QL4("server return error: \(resp.errorMessage!)")
                return
            }
            if resp.advList.count == 4 {
                self.footerAdvs = resp.advList
                self.tableView.reloadData()
            }
        }
    }
    
    func loadCourseNotify() {
        BasicService().sendRequest(ServiceConfiguration.GET_COURSE_NOTIFY, request: GetCourseNotifyRequest() ) { (resp: GetCourseNotifyResponse) -> Void in
            if resp.isFail {
                QL4("server return error: \(resp.errorMessage!)")
                return
            }
            self.courseNotifies = resp.notifies;
            self.tableView.reloadData()
        }
    }
    
    
    func loadFunctionInfos() {
        BasicService().sendRequest(ServiceConfiguration.GET_FUNCTION_INFO, request: GetFunctionInfosRequest()) {
            (resp: GetFunctionInfosResponse) -> Void in
            if resp.status != ServerResponseStatus.Success.rawValue {
                QL4("server return error: \(resp.errorMessage!)")
                return
            }
            //更新消息
            for function in resp.functions {
                self.extendFunctionStore.updateMessageCount(function.code, value: function.messageCount)
                self.extendFunctionStore.updateShow(function.code, value: function.isShowDefault)
            }
            self.tableView.reloadData()
        }

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "beforeCourseSegue" {
            let dest = segue.destinationViewController as! AlbumListController
            
            dest.courseType = sender as! CourseType
        } 
        else if segue.identifier == "loadWebPageSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            
            let params = sender as! [String: String]
            dest.url = NSURL(string: params["url"]!)
            
            dest.title = params["title"]
        } else if segue.identifier == "buyVipSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            dest.url = NSURL(string: ServiceLinkManager.MyAgentUrl)
            dest.title = "Vip购买"
        }
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        let audioItem = getAudioPlayer().currentItem
        if audioItem == nil {
            return
        }
        updatePlayingButton(playingButton)
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        performSegueWithIdentifier("searchSegue", sender: nil)
    }
    
    func refresh() {
        if (refreshing) {
            refreshControl.endRefreshing()
            return
        }
        
        refreshing = true
        loadHeaderAdv()
        
    }
    
    var footerImageInterWidth = 2
}


extension CourseMainPageViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getRowCount()
    }
    
    private func getRowCount() -> Int {
        return 2 + extendFunctionMananger.getRowCount() + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        if row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("mainpageHeaderAdvCell") as! HeaderAdvCell
            return cell

        } else if row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("courseNotifyCell") as! CourseNotifyCell
            
            if courseNotifies.count == 0 {
                cell.courseNotifyLabel.hidden = true
            } else {
                cell.courseNotifyLabel.hidden = false
                var notifyString = ""
                for notify in self.courseNotifies {
                    notifyString = notifyString + notify + " "
                }
                cell.courseNotifyLabel.text = notifyString
                cell.courseNotifyLabel.scrollDuration = 16
                cell.courseNotifyLabel.restartLabel()
            }
            
            return cell
        } else if row == getRowCount() - 1 {
             return makeAdvCell()
        } else {
            let cell = extendFunctionMananger.getFunctionCell(tableView, row: row - 2)
            return cell

        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 0 {
            return getHeaderAdvHeight()
        } else if row == 1 {
            return 18
        }else if row == getRowCount() - 1 {
            return computeAdCellHeight()
        } else {
            return extendFunctionMananger.cellHeight
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let row = indexPath.row
        if row == 0 {
            if headerAdv != nil {
                if (headerAdv?.type)! == HeaderAdv.Type_Song {
                    loading.showOverlay(view)
                    let request = GetSongInfoRequest()
                    let album = Album()
                    album.courseType = CourseType.LiveCourse
                    let reqSong = Song()
                    reqSong.album = album
                    reqSong.id = (headerAdv?.songId)!
                    request.song = reqSong
                    BasicService().sendRequest(ServiceConfiguration.GET_SONG_INFO, request: request) {
                        (resp : GetSongInfoResponse) -> Void in
                        self.loading.hideOverlayView()
                        if resp.status == ServerResponseStatus.NoEnoughAuthority.rawValue {
                            self.displayVipBuyMessage(resp.errorMessage!, delegate: self.buyPayCourseDelegate!)
                            return
                        }
                        
                        if resp.isFail {
                            self.displayMessage(resp.errorMessage!)
                            return
                        }
                        
                        let song = resp.song
                        if song == nil {
                            return
                        }
                        
                        let audioPlayer = self.getAudioPlayer()
                        //如果当前歌曲已经在播放，就什么都不需要做
                        if audioPlayer.currentItem != nil {
                            if song.id == (audioPlayer.currentItem! as! MyAudioItem).song.id {
                                self.performSegueWithIdentifier("songSegue", sender: false)
                                return
                            }
                        }
                        
                        var audioItems = [AudioItem]()
                        let songs = [song]
                        for songItem in songs {
                            var url = NSURL(string: songItem.url)
                            let audioItem = MyAudioItem(song: songItem, highQualitySoundURL: url)
                            audioItems.append(audioItem!)
                        }
                        
                        audioPlayer.delegate = nil
                        audioPlayer.playItems(audioItems, startAtIndex: 0)
                        self.performSegueWithIdentifier("songSegue", sender: false)
                        
                    }
                } else {
                    performSegueWithIdentifier("beforeCourseSegue", sender: CourseType.LiveCourse)
                    
                }
            }
        }
    }
    
    func tapAdImageHandler(sender: UITapGestureRecognizer? = nil) {
        let scrollView = sender?.view as! UIScrollView
        let index = scrollView.auk.currentPageIndex
        if index != nil {
            let params : [String: String] = ["url": ads[index!].clickUrl, "title": ads[index!].title]
            performSegueWithIdentifier("loadWebPageSegue", sender: params)
        }
    }
    
    var footerImageWidth:CGFloat {
        get {
            let screenWidth = UIScreen.mainScreen().bounds.width;
            let width = (screenWidth - CGFloat(footerImageInterWidth * 3)) / 4
            return width
        }
    }
    
    var footerImageHeight:CGFloat {
        get {
            return footerImageWidth * 1418 / 1380
        }
    }
    
    func footerAdvImageHandler(sender: UITapGestureRecognizer? = nil) {
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
        performSegueWithIdentifier("loadWebPageSegue", sender: params)
    }
    
    private func makeImage(index: Int, adv: FooterAdv) -> UIImageView {
        let x = CGFloat(index) * footerImageWidth + CGFloat(index * footerImageInterWidth);
        var y =  computeAdCellHeight() - footerImageHeight
        
        if y < 0 {
            y = 0
        }

        let imageView = UIImageView(frame: CGRectMake(x, y, footerImageWidth, footerImageHeight))
        imageView.tag = index
        if adv.imageUrl != "" {
            if let imageUrl = NSURL(string: adv.imageUrl) {
                //QL1("imageUrl: \(adv.imageUrl)")
                imageView.kf_setImageWithURL(imageUrl)
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(footerAdvImageHandler) ))
                imageView.userInteractionEnabled = true

            }
        } else {
            imageView.image = UIImage(named: "footer_ditu")
        }
        
        return imageView
    }
    
    private func makeAdvCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("footerAdvCell") as! FooterAdvCell
        if footerAdvs.count != 4 {
            footerAdvs = [FooterAdv]()
            footerAdvs.append(FooterAdv())
            footerAdvs.append(FooterAdv())
            footerAdvs.append(FooterAdv())
            footerAdvs.append(FooterAdv())
        }
        var i = 0
        footerAdvs.forEach() {
            (adv: FooterAdv) -> Void in
            cell.addSubview(makeImage(i, adv: adv))
            i = i + 1
        }
        return cell
    }


    private func computeAdCellHeight() -> CGFloat {
        let section1Height = getHeaderAdvHeight()
        let section2Height = CGFloat(extendFunctionMananger.getRowCount()) * extendFunctionMananger.cellHeight
        let total = section1Height + section2Height + 3 + 65 + 49 - 5
        var height = UIScreen.mainScreen().bounds.height - CGFloat(total)
        
        if height < footerImageHeight  {
            height = footerImageHeight
        }
        return height
    }
    
    
    private func getHeaderAdvHeight() -> CGFloat {
        let screenWidth = UIScreen.mainScreen().bounds.width
        return screenWidth * 140 / 320
    }

}
