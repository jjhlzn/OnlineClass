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
        let advancedManager = LTAdvancedManager(frame: CGRect(x: 0, y: Y, width: view.bounds.width, height: H), viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout, headerViewHandle: {[weak self] in
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
        
        //let Y: CGFloat = glt_iphoneX ? 64 + 24.0 : 64.0
        let shareView = ShareView(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 233, width: UIScreen.main.bounds.width, height: 233))
        
        
        //view.addSubview(overlay)
        //view.addSubview(shareView)
        
        let commentKB = CommentKeyboard(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 156, width: UIScreen.main.bounds.width, height: 156))
        //view.addSubview(overlay)
        
        view.addSubview(commentKB)
    }
    
}

extension NewPlayerController: LTAdvancedScrollViewDelegate {
    
    //MARK: 具体使用请参考以下
    private func advancedManagerConfig() {
        //MARK: 选中事件
        advancedManager.advancedDidSelectIndexHandle = {
            print($0)
        }
    }
    
    func glt_scrollViewOffsetY(_ offsetY: CGFloat) {
        print("offset --> ", offsetY)
    }
}


extension NewPlayerController {
    private func testLabel() -> LTHeaderView {
        return LTHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 170))
    }
}

