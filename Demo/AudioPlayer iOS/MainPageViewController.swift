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
import LTScrollView
import MJRefresh
import SnapKit

class CourseMainPageViewController: BaseUIViewController, LTTableViewProtocal, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    //@IBOutlet weak var playingButton: UIButton!
    var extendFunctionMananger = ExtendFunctionMananger.instance
    var extendFunctionStore = ExtendFunctionStore.instance
    var extendFunctionImageStore = ExtendFunctionImageStore()

    var keyValueStore = KeyValueStore()

    var loading = LoadingOverlay()
    //var refreshControl:UIRefreshControl!
    var refreshing = false
    
    var toutiao = Toutiao()
    var ads = [Advertise]()
    var zhuanLans = [ZhuanLan]()
    var jpks = [ZhuanLan]()
    var courses = [Album]()
    var questions = [Question]()
    var toutiaos = [FinanceToutiao]()
    var pos: Pos?
    
    var cellModels = [MainPageCellModel]()
    
    var buyPayCourseDelegate: ConfirmDelegate2!
    var isDisapeared = false
    var navigationManager : NavigationBarManager!
    
    
    var adOverlay: UIView?
    var isShowAd = false
    var popupAd = Advertise()
    
    let refreshHeader = MJRefreshNormalHeader()
    let mainPageNavBar = MainPageNavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = self.tabBarController?.tabBar.items
        items![0].title = "探索"
        items![1].title = "签到"
        items![2].title = "直播"
        items![3].title = "已购"
        items![4].title = "我的"
    
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        

        self.tableView.register(UINib(nibName:"QuestionHeaderCell", bundle:nil),forCellReuseIdentifier:"QuestionHeaderCell")
        self.tableView.register(UINib(nibName:"QuestionItemCell", bundle:nil),forCellReuseIdentifier:"QuestionItemCell")

        
        buyPayCourseDelegate = ConfirmDelegate2(controller: self)
        
        setExtendFuncMgrConfig()
       
        //下拉刷新设置
        refreshing = false
        
        refreshHeader.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        tableView.mj_header = refreshHeader
        
        //如果是iphoneX则，需要加长下拉的程度
        if UIDevice().isX() {
            refreshHeader.frame.size.height += 40
            let frame = refreshHeader.frame
            refreshHeader.bounds = CGRect(x: frame.origin.x, y: frame.origin.y  - 20, width: frame.width, height: frame.height)
        }
        refreshHeader.lastUpdatedTimeLabel.isHidden = true
        refreshHeader.stateLabel.isHidden = true
        
        makeCells()
        
        loadFunctionInfos()
        loadHeadAds()
        loadZhuanLanAndTuijianCourses()
        //loadQuestions()
        loadFinanceToutiaos()
        
        navigationManager = NavigationBarManager(self)
        mainPageNavBar.navigationManager = navigationManager
        mainPageNavBar.controller = self
        setNavigationBarAndTableView(self, tableView: tableView)
        //self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setNavigationBarAndTableView(_ controller: UIViewController,  tableView: UITableView?) {
        if #available(iOS 11.0, *) {
            tableView?.contentInsetAdjustmentBehavior = .never
            if UIDevice().isX() {
                tableView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            }
        } else {
            controller.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func setExtendFuncMgrConfig() {
        let screenHeight = UIScreen.main.bounds.height
        var maxRows = 3
        if screenHeight < 568 {  //568
            maxRows = 2
        }
        extendFunctionMananger.setConfig(controller: self, isNeedMore: true, showMaxRows: maxRows)
    }
    
    
    var lastOffSet : CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        lastOffSet = offsetY
        mainPageNavBar.updateNavigationForOffsetAdust(offsetY)
    }
    
    func setNavigationBar(_ offset : CGFloat = 0, updateAlways : Bool = false) {
        //updateNavigationForOffsetAdust(offset, updateAlways: updateAlways)
        mainPageNavBar.updateNavigationForOffsetAdust(offset, updateAlways: updateAlways)
    }
    
    @objc func tapSearchLabel(sender:UITapGestureRecognizer) {
        performSegue(withIdentifier: "newSearchSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //updatePlayingButton(button: playingButton)
        extendFunctionMananger.controller = self
        self.setNavigationBar(lastOffSet, updateAlways: true)
        isDisapeared = false
        
        if isShowAd {
            hidePopupAd()
        }
        
        //self.hidesBottomBarWhenPushed = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         navigationManager.setMusicBtnState()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.rightBarButtonItem  = nil
        
        isDisapeared = false
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.default
        nav?.tintColor = UIColor.black
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
            let args = sender as! [String:String]
            let dest = segue.destination as! WebPageViewController
            let url = "\(ServiceLinkManager.BuyProductUrl)?type=course&id=\(args["courseId"]!)"
            QL1(url)
            dest.url = NSURL(string: url)
            dest.title = "确认支付"
        } else if segue.identifier == "zhuanLanListSegue" {
            if sender == nil {
                let dest = segue.destination as! ZhuanLanListVC
                dest.type = ZhuanLanListVC.TYPE_ZHUANLAN
            } else {
                let args = sender as! [String:String]
                
                let dest = segue.destination as! ZhuanLanListVC
                dest.type = args["type"]!
            }
            
        }  else if segue.identifier == "answerQuestionSegue" {
            let args = sender as! [String:AnyObject]
            let dest = segue.destination as! AnswerQuestionVC
            dest.toUserId = args["toUserId"] as? String
            dest.toUserName = args["toUserName"] as? String
            dest.question = args["question"] as? Question
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
            audioItems.append(audioItem!)

            audioPlayer.delegate = nil
            audioPlayer.play(items: audioItems, startAtIndex: 0)

            (segue.destination as! NewPlayerController).hidesBottomBarWhenPushed = true
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
            //refreshControl.endRefreshing()
            refreshHeader.endRefreshing()
            return
        }
        
        refreshing = true
        loadHeadAds()
        //loadToutiao()
        loadFunctionInfos()
        loadZhuanLanAndTuijianCourses()
        //loadQuestions()
        loadFinanceToutiaos()
    }
    
    @IBAction func viewZhuanLanListPressed(_ sender: Any) {
        var sender = [String:String]()
        sender["type"] = ZhuanLanListVC.TYPE_ZHUANLAN
        performSegue(withIdentifier: "zhuanLanListSegue", sender: sender)
    }
    
    @IBAction func viewJpkPressed(_ sender: Any) {
        var sender = [String:String]()
        sender["type"] = ZhuanLanListVC.TYPE_JPK
        performSegue(withIdentifier: "zhuanLanListSegue", sender: sender)
    }
    
    
    @IBAction func viewAllToutiaoPressed(_ sender: Any) {
        //performSegue(withIdentifier: "zhuanLanListSegue", sender: nil)
        var sender = [String:String]()
        sender["title"] = "金融宝典"
        sender["url"] = ServiceLinkManager.JunhuokuUrl
        performSegue(withIdentifier: "loadWebPageSegue", sender: sender)
    }
    
}


extension CourseMainPageViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellModels.count
    }
    
    func dummyDidSelectAction(tableView: UITableView, indexPath: IndexPath) -> Void {
    }

    
    private func makeCells() {
        cellModels = [MainPageCellModel]()
    
        let headerAdvModel = MainPageHeaderAdvModel()
        headerAdvModel.ads = ads
        let headerCellModel = MainPageCellModel.headerAdv(headerAdvModel)
        cellModels.append(headerCellModel)
        
        //for _ in 0..<extendFunctionMananger.getRowCount() {
            cellModels.append(MainPageCellModel.extendFunction)
        //}
        
        if pos != nil {
            cellModels.append(MainPageCellModel.seperator)
            cellModels.append(MainPageCellModel.pos(pos!))
        }
        
        if courses.count > 0 {
            cellModels.append(MainPageCellModel.seperator)
            cellModels.append(MainPageCellModel.courseHeader)
            
            for index in 0..<courses.count {
                cellModels.append(MainPageCellModel.course(courses[index]))
            }
        }
        
        if toutiaos.count > 0 {
            cellModels.append(MainPageCellModel.seperator)
            cellModels.append(MainPageCellModel.toutiaoHeader)
            
            for index in 0..<toutiaos.count {
                cellModels.append(MainPageCellModel.toutiao(toutiaos[index]))
            }
        }
        
        if jpks.count > 0 {
            cellModels.append(MainPageCellModel.seperator)
            cellModels.append(MainPageCellModel.jpkHeader)
            
            for index in 0..<jpks.count {
                cellModels.append(MainPageCellModel.jpk(jpks[index]))
            }
        }
        
        
        if zhuanLans.count > 0 {
            cellModels.append(MainPageCellModel.seperator)
            cellModels.append(MainPageCellModel.zhuanLanHeader)
            
            for index in 0..<zhuanLans.count {
                cellModels.append(MainPageCellModel.zhuanLan(zhuanLans[index]))
            }
        }
        
        /*
        if questions.count > 0 {
            cellModels.append(MainPageCellModel.seperator)
            cellModels.append(MainPageCellModel.questionHeader)
            
            for index in 0..<questions.count {
                cellModels.append(MainPageCellModel.question(questions[index]))
            }
        } */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        //return cells[row]
        let cellModel = cellModels[row]
        //var cell : UITableViewCell?
        switch cellModel {
        case .headerAdv(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainpageHeaderAdvCell") as! HeaderAdvCell
            cell.controller = self
            cell.initialize()
            cell.ads = model.ads
            cell.update()
            return cell
        case .extendFunction:
            let cell =  extendFunctionMananger.getFunctionCell(tableView: tableView, row: 0)
            return cell
        case .pos(let pos):
            let cell = tableView.dequeueReusableCell(withIdentifier: "posCell") as! PosCell
            cell.pos = pos
            cell.viewController = self
            cell.update()
            return cell
        case .toutiaoHeader:
            return tableView.dequeueReusableCell(withIdentifier: "toutiaoHeaderCell")!
        case .toutiao(let toutiao):
            let toutiaoCell = tableView.dequeueReusableCell(withIdentifier: "toutiaoCell") as! ToutiaoCell
            toutiaoCell.toutiao = toutiao
            toutiaoCell.update()
            return toutiaoCell
        case .courseHeader:
            return tableView.dequeueReusableCell(withIdentifier: "tuijianCourseHeaderCell")!
        case .course(let course):
            let courseCell = tableView.dequeueReusableCell(withIdentifier: "tuijianCourseCell") as! MainPageCourseCell
            courseCell.course = course
            courseCell.update()
            return courseCell
        case .jpkHeader:
            return tableView.dequeueReusableCell(withIdentifier: "jpkHeaderCell")!
        case .jpk(let jpk):
            let jpkCell = tableView.dequeueReusableCell(withIdentifier: "zhuanLanCell") as! ZhuanLanCell
            jpkCell.zhuanLan = jpk
            jpkCell.update()
            return jpkCell
        case .zhuanLanHeader:
            return tableView.dequeueReusableCell(withIdentifier: "zhuanLanHeaderCell")!
        case .zhuanLan(let zhuanLan):
            let zhuanLanCell = tableView.dequeueReusableCell(withIdentifier: "zhuanLanCell") as! ZhuanLanCell
            zhuanLanCell.zhuanLan = zhuanLan
            zhuanLanCell.update()
            return zhuanLanCell
        case .questionHeader:
            let questionHeaderCell : QuestionHeaderCell = cellWithTableView(tableView)
            questionHeaderCell.viewController = self
            return questionHeaderCell
        case .question(let question):
            let questionItemCell : QuestionItemCell = cellWithTableView(tableView)
            questionItemCell.question = question
            questionItemCell.viewController = self
            questionItemCell.update()
            return questionItemCell
        case .seperator:
            return tableView.dequeueReusableCell(withIdentifier: "seperatorCell")!
        }
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let cellModel = cellModels[row]
        switch cellModel {
        case .headerAdv(_):
            return getHeaderAdvHeight()
        case .extendFunction:
            return extendFunctionMananger.cellHeight
        case .pos(_):
            return UIScreen.main.bounds.width / 375 * 90.0
        case .toutiaoHeader, .courseHeader, .jpkHeader, .zhuanLanHeader, .questionHeader:
            return 52
        case .toutiao(_):
            return 30
        case .course(_):
            return UIScreen.main.bounds.width / 375 * 180.0
        case .jpk(_), .zhuanLan(_):
            return 110
        case .question(let question):
            let questionItemCell : QuestionItemCell = cellWithTableView(tableView)
            questionItemCell.question = question
            questionItemCell.viewController = self
            questionItemCell.update()
            return questionItemCell.getHeight()
        case .seperator:
            return 8
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        let row = indexPath.row
        let cellModel = cellModels[row]
        switch cellModel {
        case .toutiao(let toutiao):
            var sender = [String:String]()
            sender["title"] = toutiao.title
            sender["url"] = toutiao.link
            self.performSegue(withIdentifier: "loadWebPageSegue", sender: sender)
            return
        case .course(let album):
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
            self.jumpToCourse(album: album)
            return
        case .jpk(let zhuanLan), .zhuanLan(let zhuanLan):
            var sender = [String:String]()
            sender["title"] = zhuanLan.name
            sender["url"] = zhuanLan.url
            self.performSegue(withIdentifier: "loadWebPageSegue", sender: sender)
            return
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func jumpToCourse(album: Album) {
        let viewControllerStoryboardId = "NewPlayerController"
        let storyboardName = "Main"
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: viewControllerStoryboardId) as! NewPlayerController
        vc.hasBottomBar = false
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    

    
    private func getHeaderAdvHeight() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth / 375 * 224
    }

}

extension CourseMainPageViewController  {
    
    func showPopupAd(_ ad : Advertise) {
        self.isShowAd = true
        adOverlay = UIView(frame: UIScreen.main.bounds)
        adOverlay!.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
        let ration : CGFloat = 0.6
        let imageWidth = UIScreen.main.bounds.width * ration
        let imageHeight = UIScreen.main.bounds.width * ration * 1.5
        let imageView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width * (1 - ration) / 2, y: UIScreen.main.bounds.height * 0.15 , width: imageWidth, height: imageHeight))
        //imageView.image = UIImage(named: "icon")
        imageView.kf.setImage(with: URL(string: ad.imageUrl)!)
        adOverlay!.addSubview(imageView)
        
        imageView.isUserInteractionEnabled = true
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(tapImageAd))
        imageView.addGestureRecognizer(tapImageGesture)
        
        let closeAdWidth : CGFloat = 40
        let closeAdBtn = UIImageView(frame: CGRect(x: (UIScreen.main.bounds.width - closeAdWidth) / 2, y: UIScreen.main.bounds.height * ( 1 - 0.15) , width: closeAdWidth, height: closeAdWidth))
        closeAdBtn.image = UIImage(named: "closeAdButton")
        adOverlay!.addSubview(closeAdBtn)
        
        closeAdBtn.isUserInteractionEnabled = true
        let closeAdGesture = UITapGestureRecognizer(target: self,  action: #selector(hidePopupAd))
        closeAdBtn.addGestureRecognizer(closeAdGesture)
        
        UIApplication.shared.keyWindow?.addSubview(adOverlay!)
    }
    
    @objc func tapImageAd() {
        var params = [String:String]()
        
        if popupAd.type == Advertise.WEB {
            params["title"] = popupAd.title
            params["url"] = popupAd.clickUrl
            performSegue(withIdentifier: "loadWebPageSegue", sender: params)
        } else if popupAd.type == Advertise.COURSE {
            let album = Album()
            album.id = popupAd.id
            album.isReady = true
            jumpToCourse(album: album)
        }
        hidePopupAd()
    }
    
    @objc func hidePopupAd() {
        QL1("hidePopupAd")
        if adOverlay != nil {
            adOverlay?.removeFromSuperview()
        }
    }

    
    @objc func loadHeadAds() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_MAIN_PAGE_ADS, request: GetMainPageAdsRequest()) {
            (resp: GetMainPageAdsResponse) -> Void in
            if self.refreshing {
                self.refreshHeader.endRefreshing()
            }
            self.refreshing = false
            
            self.ads = resp.ads
            
            self.makeCells()
            self.tableView.reloadData()
            
            if resp.popupAd.imageUrl != "" && resp.popupAd.imageUrl != nil {
                let cacheImageUrl = self.keyValueStore.get(key: KeyValueStore.key_popupAdImageUrl, defaultValue: "")
                
                if cacheImageUrl != resp.popupAd.imageUrl {
                    self.keyValueStore.save(key: KeyValueStore.key_popupAdImageUrl, value: resp.popupAd.imageUrl)
                    self.popupAd = resp.popupAd
                    self.showPopupAd(resp.popupAd)
                }
            }
        }
    }
    
    @discardableResult
    func loadFunctionInfos() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_FUNCTION_INFO, request: GetFunctionInfosRequest()) {
            (resp: GetFunctionInfosResponse) -> Void in
            if resp.status != ServerResponseStatus.Success.rawValue {
                QL4("server return error: \(resp.errorMessage!)")
                return
            }
            
            var functions = [ExtendFunction]()
            let extendFuncMgr = ExtendFunctionMananger.instance
            //更新消息
            //var imageUrls = [String]()
            for function in resp.functions {
                let extendFunc = extendFuncMgr.makeFunction(imageName: function.imageUrl, name: function.name, code: function.code, url: function.clickUrl, messageCount: function.messageCount, selectorName: function.action)
                
                QL1("\(function.name) \(function.action)")
                
                functions.append(extendFunc)
                
            }
            extendFuncMgr.functions = functions
            
            self.makeCells()
            self.tableView.reloadData()
            //self.downloadFunctionImages(imageUrls: imageUrls)
        }
        
    }
    
    func loadZhuanLanAndTuijianCourses() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_ZHUANLAN_AND_TUIJIAN_COURSES, request: GetZhuanLanAndTuijianCoursesRequest()) {
            (resp: GetZhuanLanAndTuijianCoursesResponse) -> Void in
            if self.refreshing {
                self.refreshHeader.endRefreshing()
            }
            self.refreshing = false
            
            self.zhuanLans = resp.zhuanLans
            self.courses = resp.albums
            self.jpks = resp.jpks
            self.pos = resp.pos
            
            self.makeCells()
            self.tableView.reloadData()
        }
    }

    /*
    func loadQuestions() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_QUESTIONS, request: GetQuestionsRequest()) {
            (resp: GetQuestionsResponse) -> Void in
            if self.refreshing {
                self.refreshHeader.endRefreshing()
            }
            self.refreshing = false
            
            self.questions = resp.questions
            
            self.makeCells()
            self.tableView.reloadData()
        }
    } */
    
    func loadFinanceToutiaos() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_FINANCE_TOUTIAOS, request: GetFinanceToutiaoRequest()) {
            (resp: GetFinanceToutiaoResponse) -> Void in
            if self.refreshing {
                self.refreshHeader.endRefreshing()
            }
            self.refreshing = false
            
            self.toutiaos = resp.toutiaos
            
            self.makeCells()
            self.tableView.reloadData()
        }
    }
    
}
