 //
//  TestIAPController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/9/7.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import StoreKit
import LTScrollView
import KDEAudioPlayer
import QorumLogs

class NewPlayerController: BaseUIViewController, UIScrollViewDelegate {

    var hasBottomBar: Bool = true
    var loading : LoadingOverlay!
    var song : LiveSong?
    var titleView : UIView?
    var bgImage: UIImage?
    var showdowImage: UIImage?
    var imageView : UIImageView?
    var bgColor: UIColor?
    var isTouming : Bool = true
    
    var timer : Timer!
    
    //var shareOverlay: UIView!
    var shareView: ShareView!
    var commentKeyboard: CommentKeyboard?
    
    var  headerView : PlayerHeaderView!
    
    private lazy var viewControllers: [UIViewController] = {
        let oneVc = CourseOverviewVC()
        oneVc.song = song
        oneVc.hasBottomBar = self.hasBottomBar
        let threeVc = BaomingVC()
        return [oneVc, threeVc]
    }()
    
    private lazy var titles: [String] = {
        return ["课程介绍", "我要报名"]
    }()
    
    //设置Header的样式
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
        layout.titleViewBgColor = UIColor.white
        layout.titleColor = UIColor(r: 0, g: 0, b: 0)
        layout.titleFont = UIFont(name: "HelveticaNeue", size: 16)
        layout.titleSelectColor = UIColor(r: 0xCA, g: 0x9A, b: 0x60)
        layout.bottomLineColor = UIColor(r: 0xCA, g: 0x9A, b: 0x60)
        layout.pageBottomLineColor = UIColor(r: 230, g: 230, b: 230)
        layout.isAverage = true
        layout.sliderWidth = 80
        
        return layout
    }()
    
    private lazy var advancedManager: LTAdvancedManager = {

        let advancedManager = LTAdvancedManager(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: UIScreen.main.bounds.height), viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout, headerViewHandle: {[weak self] in
            guard let strongSelf = self else { return UIView() }
            let headerView = strongSelf.testLabel()
            return headerView
        })
        advancedManager.delegate = self
        return advancedManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let audioPlayer = Utils.getAudioPlayer()
        //self.song = (audioPlayer.currentItem as! MyAudioItem).song as! LiveSong
        
        audioPlayer.delegate = self
        headerView = PlayerHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: PlayerHeaderView.getHeight()))
        //headerView.frame.size.height = headerView.getHeight()
        headerView.audioPlayer = audioPlayer
        
        view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(advancedManager)
        advancedManagerConfig()
        
        var Y = UIScreen.main.bounds.height - 233
        if hasBottomBar {
            Y = Y - Utils.getTabHeight(controller: self)
        }
        shareView = ShareView(frame: CGRect(x : 0, y: Y, width: UIScreen.main.bounds.width, height: 233), controller: self)

        setNavigationBar(true)
        
        if audioPlayer.currentItem == nil {
            loading = LoadingOverlay()
            loading.showOverlay(view: self.view)
            loadCourses()
        } else {
            self.song = Utils.getCurrentSong()
            loadViewAfterGetSong()
        }
    }
    
    private func loadViewAfterGetSong() {
        (self.viewControllers[0] as! CourseOverviewVC).song = Utils.getCurrentSong()
        (self.viewControllers[0] as! CourseOverviewVC).refresh()
        self.song = Utils.getCurrentSong()
        self.headerView.update()
       
        self.initCommentKeybaord()
    }
    
    private func initCommentKeybaord() {
        var y = UIScreen.main.bounds.height - 40
        if UIDevice().isX() {
            if hasBottomBar {
                y = UIScreen.main.bounds.height - Utils.getTabHeight(controller: self) - 40
            } else {
                y -= 24
            }
        } else {
            if hasBottomBar {
                y -= Utils.getTabHeight(controller: self)
            }
        }
        
        commentKeyboard = CommentKeyboard(frame: CGRect(x : 0, y: y, width: UIScreen.main.bounds.width, height: 40), shareView: shareView, viewController: self, liveDelegate: viewControllers[0] as! LiveCommentDelegate)
        
        view.addSubview(commentKeyboard!)
        commentKeyboard?.commentController.addKeyboardNotify()
    }
    
    @objc func loadListenCount() {
        if song != nil {
            let req = GetLiveListernerCountRequest(song: Utils.getCurrentSong())
            BasicService().sendRequest(url: ServiceConfiguration.GET_LIVE_LISTERNER_COUNT, request: req) {
                (resp: GetLiveListernerCountResponse) -> Void in
                let listenerCount = resp.count
                self.headerView.updateListenerCountLabel(listenerCount)
            }
        }
    }
    
    
    @objc func backPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func sharePressed(_ isTranslucent : Bool) {
        shareView.show()
    }
    
    func setBackButton(_ isTranslucent : Bool) {
        
        let b = UIButton(type: .custom)
        var imageName = "back_black"
        if isTranslucent {
            imageName = "back_white"
        }
        b.setImage( UIImage(named: imageName), for: .normal)
        b.frame = CGRect(x: -20, y: 0, width: 35, height: 35)
        let button = UIBarButtonItem(customView: b)
        
        b.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem  = button
    }
    
    func setShareButton(_ isTranslucent : Bool) {
        let b = UIButton(type: .custom)
        var imageName = "share_black"
        if isTranslucent {
            imageName = "share_white"
        }
        b.setImage( UIImage(named: imageName), for: .normal)
        b.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        let button = UIBarButtonItem(customView: b)
        b.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem  = button
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBar(self.isTouming)
        commentKeyboard?.commentController.addKeyboardNotify()
        
        let audioPlayer = Utils.getAudioPlayer()
        audioPlayer.delegate = self
    
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.loadListenCount), userInfo: nil, repeats: true)
        
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resumeNavigationBar()
        
        commentKeyboard?.commentController.removeKeyboardNotify()
        commentKeyboard?.commentController.dispose()
        
        Utils.getAudioPlayer().delegate = nil
        if self.navigationController?.viewControllers.index(of: self) == nil {
            if let navigatoinViewController = (self.parent as? UINavigationController) {
                if let delegate = navigatoinViewController.topViewController as? AudioPlayerDelegate {
                    Utils.getAudioPlayer().delegate = delegate
                }
            }
        }
        
        timer.invalidate()
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.default
        nav?.tintColor = UIColor.black
        
    }
    
    func resumeNavigationBar() {
        setNavigationBar(true)
    }
    
    
    func setNavigationBar(_ isTranslucent : Bool, offset : CGFloat = 0) {
        if !hasBottomBar {
            if self.navigationController?.backdropImageView == nil {
                self.navigationController?.backdropImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 315, height:88))
            }
        }
        
        if isTranslucent {
            let alpha = (offset / Utils.getNavigationBarHeight()) > 1.0 ? 1 : offset / Utils.getNavigationBarHeight()
            //QL1(alpha)
            self.navigationController?.setBarColor(image: UIImage(), color: nil, alpha: alpha)
            let label = UILabel()
            self.navigationItem.titleView = label
            
            let nav = self.navigationController?.navigationBar
            nav?.barStyle = UIBarStyle.black
            nav?.tintColor = UIColor.white
        } else {
            self.navigationController?.setBarColor(image: UIImage(), color: UIColor.white, alpha: 1)
            let searchLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            searchLabel.backgroundColor =  UIColor(white: 0, alpha: 0)
            searchLabel.text = song?.name
            searchLabel.textColor =  UIColor.black
            searchLabel.textAlignment = .center
            self.navigationItem.titleView = searchLabel
            
            let nav = self.navigationController?.navigationBar
            nav?.barStyle = UIBarStyle.default
            nav?.tintColor = UIColor.black
        }
        
        setShareButton(isTranslucent)
        
        if !hasBottomBar {
            setBackButton(isTranslucent)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "loadWebSegue" {
            let dest = segue.destination as! WebPageViewController
            let params = sender as! [String: String]
            dest.url = NSURL(string: params["url"]!)
            dest.title = params["title"]
        }
    }
    
    override func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        //QL1("audioPlayer:didChangeStateFrom called, from = \(from), to = \(state)")
        headerView.updateMusicButton()
    }
    
    func loadCourses() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_ZHUANLAN_AND_TUIJIAN_COURSES, request: GetZhuanLanAndTuijianCoursesRequest()) {
            (resp: GetZhuanLanAndTuijianCoursesResponse) -> Void in
            if resp.isFail {
                self.loading.hideOverlayView()
                self.displayMessage(message: resp.errorMessage!)
                return
            }
            let courses = resp.albums
            if courses.count > 0 {
                let album = courses[0]
                let req = GetAlbumSongsRequest(album: album)
                _ = BasicService().sendRequest(url: ServiceConfiguration.GET_ALBUM_SONGS, request: req) {
                    (resp: GetAlbumSongsResponse) -> Void in
                    
                    //self.loading.hideOverlayView()
                    if resp.status == ServerResponseStatus.TokenInvalid.rawValue {
                        self.loading.hideOverlayView()
                        self.displayMessage(message: "请重新登录")
                        return
                    }
                    
                    //目前这个逻辑之针对VIP课程权限够的情况
                    if resp.status == ServerResponseStatus.NoEnoughAuthority.rawValue {
                        self.loading.hideOverlayView()
                        self.displayMessage(message: "你没有权限")
                        //self.buyPayCourseDelegate.courseId = album.id
                        //self.displayVipBuyMessage(message: resp.errorMessage!, delegate: self.buyPayCourseDelegate!)
                        return
                    }
                    
                    let songs = resp.resultSet
                    if (songs.count == 0) {
                        self.loading.hideOverlayView()
                        self.displayMessage(message: "获取课程失败")
                        return
                    }
                    
                    let song = songs[0]
                   
                    
                    let audioPlayer = self.getAudioPlayer()
                    //如果当前歌曲已经在播放，就什么都不需要做
                    
                    var audioItems = [AudioItem]()
                    
                    let   url = URL(string: song.url)
                    let audioItem = MyAudioItem(song: song, highQualitySoundURL: url)
                    audioItems.append(audioItem!)
                    audioPlayer.delegate = self
                    audioPlayer.play(items: audioItems, startAtIndex: 0)
                    self.loading.hideOverlayView()
                    self.loadViewAfterGetSong()
                }
            }  else {
                self.loading.hideOverlayView()
            }
            
        }
    }
}

extension NewPlayerController: LTAdvancedScrollViewDelegate {
    func jumpToWebPage(sender: [String:String]) {
        let viewControllerStoryboardId = "WebPageViewController"
        let storyboardName = "Main"
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: viewControllerStoryboardId) as! WebPageViewController
        let params = sender as! [String: String]
        vc.url = NSURL(string: params["url"]!)
        vc.title = params["title"]
        if !hasBottomBar {
            self.hidesBottomBarWhenPushed = true
        }
        self.navigationController?.pushViewController(vc, animated: true)
        //
        //self.hidesBottomBarWhenPushed = false
    }
    
    private func advancedManagerConfig() {
        //MARK: 选中事件
        advancedManager.advancedDidSelectIndexHandle = {
            print($0)
            
            let index = $0
            if index == 1 {
                var sender = [String:String]()
                if self.song != nil {
                    sender["url"] = (self.song?.advUrl)!
                    sender["title"] = "我要报名"
                    
                    //self.performSegue(withIdentifier: "loadWebSegue", sender: sender)
                    self.jumpToWebPage(sender: sender)

                }
                
            }
        }
    }
    
    func glt_scrollViewOffsetY(_ offsetY: CGFloat) {
        //QL1(offsetY)
        let Y: CGFloat = Utils.getNavigationBarHeight()
        self.isTouming = !( offsetY > Y )
        if offsetY > Y {
            setNavigationBar(false, offset: offsetY)
        } else {
            setNavigationBar(true,  offset: offsetY)
        }
    }
}


extension NewPlayerController {
    private func testLabel() -> LTHeaderView {
        //let H = 229.0 * UIScreen.main.bounds.width / 375.0
        QL1("PlayerHeaderView.height = \(PlayerHeaderView.getHeight())")
        let headerView = LTHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: PlayerHeaderView.getHeight()))
        
        headerView.headerView = self.headerView
        headerView.headerView.updateConstraints()
        headerView.initialize()
        return headerView
    }
}

