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

class NewPlayerController: UIViewController, UIScrollViewDelegate, AudioPlayerDelegate {
   
    var song : LiveSong!
    var titleView : UIView?
    var bgImage: UIImage?
    var showdowImage: UIImage?
    var imageView : UIImageView?
    var bgColor: UIColor?
    var isTouming : Bool = true
    
    var timer : Timer!
    
    //var shareOverlay: UIView!
    var shareView: ShareView!
    var commentKeyboard: CommentKeyboard!
    
    var  headerView : PlayerHeaderView!
    
    
    private lazy var viewControllers: [UIViewController] = {
        let oneVc = CourseOverviewVC()
        let twoVc = BeforeCourseVC()
        let threeVc = BaomingVC()
        return [oneVc, twoVc, threeVc]
    }()
    
    private lazy var titles: [String] = {
        return ["课程介绍", "往期课程", "我要报名"]
    }()
    
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
        layout.titleViewBgColor = UIColor.white
        layout.titleColor = UIColor(r: 0, g: 0, b: 0)
        layout.titleSelectColor = UIColor(r: 0xCA, g: 0x9A, b: 0x60)
        layout.bottomLineColor = UIColor(r: 0xCA, g: 0x9A, b: 0x60)
        layout.pageBottomLineColor = UIColor(r: 230, g: 230, b: 230)
        layout.isAverage = true
        layout.sliderWidth = 30
        
       // layout.sliderHeight = 5
        return layout
    }()
    
    private lazy var advancedManager: LTAdvancedManager = {
        let Y: CGFloat = glt_iphoneX ? 64 + 24.0 : 64.0
        let H: CGFloat = glt_iphoneX ? (view.bounds.height - Y - 34) : view.bounds.height - Y
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
        self.song = (audioPlayer.currentItem as! MyAudioItem).song as! LiveSong
        
        audioPlayer.delegate = self
        headerView = PlayerHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 229))
        headerView.audioPlayer = audioPlayer
        
        view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(advancedManager)
        advancedManagerConfig()
        
        
        shareView = ShareView(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 233, width: UIScreen.main.bounds.width, height: 233), controller: self)

        var y = UIScreen.main.bounds.height - 40
        if UIDevice().isX() {
            y -= 24
        }
        commentKeyboard = CommentKeyboard(frame: CGRect(x : 0, y: y, width: UIScreen.main.bounds.width, height: 40), shareView: shareView, viewController: self, liveDelegate: viewControllers[0] as! LiveCommentDelegate)
        
        view.addSubview(commentKeyboard)
        setNavigationBar(true)
        
        
    }
    
    @objc func loadListenCount() {
        let req = GetLiveListernerCountRequest(song: Utils.getCurrentSong())
        BasicService().sendRequest(url: ServiceConfiguration.GET_LIVE_LISTERNER_COUNT, request: req) {
            (resp: GetLiveListernerCountResponse) -> Void in
            let listenerCount = resp.count
            self.headerView.updateListenerCountLabel(listenerCount)
        }
    }
    
    func setBackButton(_ isTranslucent : Bool) {
        let b = UIButton(type: .custom)
        
        var imageName = "back_black"
        if isTranslucent {
            imageName = "back_white"
        }
        b.setImage( UIImage(named: imageName), for: .normal)
        b.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
        let button = UIBarButtonItem(customView: b)
        b.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem  = button
    }
    
    
    @objc func backPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setShareButton(_ isTranslucent : Bool) {
        let b = UIButton(type: .custom)
        var imageName = "share_black"
        if isTranslucent {
            imageName = "share_white"
        }
        b.setImage( UIImage(named: imageName), for: .normal)
        b.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
        let button = UIBarButtonItem(customView: b)
        b.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem  = button
    }
    
    @objc func sharePressed(_ isTranslucent : Bool) {
        shareView.show()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("NewPlayerController viewWillAppear called")
        setNavigationBar(self.isTouming)
        
        commentKeyboard.commentController.addKeyboardNotify()
        
        let audioPlayer = Utils.getAudioPlayer()
        
        audioPlayer.delegate = self
    
       timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.loadListenCount), userInfo: nil, repeats: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resumeNavigationBar()
        
        commentKeyboard.commentController.removeKeyboardNotify()
        commentKeyboard.commentController.dispose()
        
        Utils.getAudioPlayer().delegate = nil
        if self.navigationController?.viewControllers.index(of: self) == nil {
            if let navigatoinViewController = (self.parent as? UINavigationController) {
                if let delegate = navigatoinViewController.topViewController as? AudioPlayerDelegate {
                    Utils.getAudioPlayer().delegate = delegate
                }
            }
        }
        
        timer.invalidate()
    }
    
    func resumeNavigationBar() {
        setNavigationBar(true)
    }
    
    func setNavigationBar(_ isTranslucent : Bool) {
        if self.navigationController?.backdropImageView == nil {
            self.navigationController?.backdropImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 315, height:88))
        }
        
        if isTranslucent {
            self.navigationController?.setBarColor(image: UIImage(), color: nil, alpha: 0)
            let label = UILabel()
            self.navigationItem.titleView = label
        } else {
            self.navigationController?.setBarColor(image: UIImage(), color: UIColor.white, alpha: 1)
            let searchLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            
            searchLabel.backgroundColor =  UIColor(white: 0, alpha: 0)
            searchLabel.text = song.name
            searchLabel.textColor =  UIColor.black
            searchLabel.textAlignment = .center
            self.navigationItem.titleView = searchLabel
        }
        
        setShareButton(isTranslucent)
        setBackButton(isTranslucent)

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
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        QL1("audioPlayer:didChangeStateFrom called, from = \(from), to = \(state)")
        //headerView.updateMusicButton()
        headerView.updateMusicButton()
        
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float) {
        QL1("audioPlayer:didUpdateProgressionTo called: \(percentageRead)")
    }
}

extension NewPlayerController: LTAdvancedScrollViewDelegate {
    private func advancedManagerConfig() {
        //MARK: 选中事件
        advancedManager.advancedDidSelectIndexHandle = {
            print($0)
            let index = $0
            if index == 2 {
                var sender = [String:String]()
                sender["url"] = "http://www.baidu.com"
                sender["title"] = "测试"
                self.performSegue(withIdentifier: "loadWebSegue", sender: sender)
            }
        }
    }
    
    func glt_scrollViewOffsetY(_ offsetY: CGFloat) {
        //print("offset --> ", offsetY)
        let Y: CGFloat = glt_iphoneX ? 64 + 24.0 : 64.0
        self.isTouming = !( offsetY > Y )
        if offsetY > Y {
            setNavigationBar(false)
        } else {
            setNavigationBar(true)
        }
    }
}


extension NewPlayerController {
    private func testLabel() -> LTHeaderView {
        //let H = 229.0 * UIScreen.main.bounds.width / 375.0
        let headerView = LTHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 229))
        headerView.headerView = self.headerView
        headerView.initialize()
        return headerView
    }
}

