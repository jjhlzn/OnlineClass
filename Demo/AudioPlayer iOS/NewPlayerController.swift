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

class NewPlayerController: UIViewController, UIScrollViewDelegate {
   
    var titleView : UIView?
    var bgImage: UIImage?
    var showdowImage: UIImage?
    var imageView : UIImageView?
    var bgColor: UIColor?
    var isTouming : Bool = true
    
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
        let advancedManager = LTAdvancedManager(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout, headerViewHandle: {[weak self] in
            guard let strongSelf = self else { return UIView() }
            let headerView = strongSelf.testLabel()
            return headerView
        })
        advancedManager.delegate = self
        
      
      
        return advancedManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(advancedManager)
        advancedManagerConfig()
        
        let overlay = UIView(frame: UIScreen.main.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
        let shareView = ShareView(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 233, width: UIScreen.main.bounds.width, height: 233))
        
        //view.addSubview(overlay)
        //view.addSubview(shareView)
        
        let commentKB = CommentKeyboard(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 156, width: UIScreen.main.bounds.width, height: 156))
        //view.addSubview(overlay)
        
        view.addSubview(commentKB)
        setNavigationBar(true)
        
       
    }
    override func viewWillAppear(_ animated: Bool) {
        print("NewPlayerController viewWillAppear called")
        setNavigationBar(self.isTouming)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resumeNavigationBar()
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
            searchLabel.text = "测试"
            searchLabel.textColor =  UIColor.black
            searchLabel.textAlignment = .center
            self.navigationItem.titleView = searchLabel
        }
        /*
        if isTranslucent {
            self.bgImage = self.navigationController?.navigationBar.backgroundImage(for: .default)
            self.showdowImage = self.navigationController?.navigationBar.shadowImage
            //self.bgColor = self.navigationController?.view.backgroundColor
            
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = isTranslucent
            //self.navigationController?.view.backgroundColor = .clear
            self.titleView = self.navigationItem.titleView
            let label = UILabel()
            label.backgroundColor = UIColor.white
            self.navigationItem.titleView = label
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(self.bgImage, for: .default)
            self.navigationController?.navigationBar.shadowImage = self.showdowImage
            self.navigationController?.view.backgroundColor = UIColor.white
            
            self.navigationController?.navigationBar.isTranslucent = isTranslucent
            let searchLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))

            searchLabel.backgroundColor =  UIColor(white: 0, alpha: 0)
            searchLabel.text = "测试"
            searchLabel.textColor =  UIColor.black
            searchLabel.textAlignment = .center
            self.navigationItem.titleView = searchLabel
        } */
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
}

extension NewPlayerController: LTAdvancedScrollViewDelegate {
    
    //MARK: 具体使用请参考以下
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
        let H = 229.0 * UIScreen.main.bounds.width / 375.0
        return LTHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 229))
    }
}

