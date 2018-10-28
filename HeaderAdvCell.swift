//
//  HeaderAdvCell.swift
//  jufangzhushou
//
//  Created by 金军航 on 17/1/9.
//  Copyright © 2017年 tbaranes. All rights reserved.
//

import UIKit
import FSPagerView
import Gifu
import QorumLogs

class HeaderAdvCell: UITableViewCell, FSPagerViewDataSource, FSPagerViewDelegate {
    var controller : UIViewController?
    @IBOutlet weak var view: UIView!

    public var ads : [Advertise] = [Advertise]()
    public var toutiao = Toutiao()
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return ads.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "mainpage_pagerview_cell", at: index)
        cell.textLabel?.backgroundColor = nil
        cell.contentView.layer.shadowRadius = 0
        cell.imageView?.contentMode = .scaleToFill
        cell.imageView?.kf.setImage(with: URL(string: ads[index].imageUrl))
        cell.textLabel?.text = String("")
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        var sender = [String:String]()
        let ad =  self.ads[index]
        pagerView.deselectItem(at: index, animated: true)
        if self.ads[index].type == Advertise.WEB {
            sender["url"] = ad.clickUrl
            sender["title"] = ad.title
            self.controller?.performSegue(withIdentifier: "loadWebPageSegue", sender: sender)
        } else if self.ads[index].type == Advertise.COURSE {
            let album = Album()
            album.id = ad.id
            album.isReady = true
            (controller as! CourseMainPageViewController).jumpToCourse(album: album)
        }
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        self.pagerControl?.currentPage = index
    }
    
    var pagerView: FSPagerView?
    var pagerControl: FSPageControl?
    
    func makeViews() {
        let screenWidth = UIScreen.main.bounds.width
        let frame1 = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth / 375 * 224 )
        pagerView = FSPagerView(frame: frame1)
        pagerView?.dataSource = self
        pagerView?.delegate = self
        pagerView?.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "mainpage_pagerview_cell")
        self.view.addSubview(pagerView!)
        // Create a page control
        
        let frame2 = CGRect(x: (screenWidth - 150) / 2, y: screenWidth / 375 * 224 - 20, width: 150, height: 20)
        pagerControl = FSPageControl(frame: frame2)
        self.view.addSubview(pagerControl!)
        
        pagerView?.automaticSlidingInterval = 5.0
        pagerView?.backgroundColor = UIColor.white
        pagerView?.isInfinite = true
        pagerView?.dataSource = self
        pagerView?.delegate = self
        //pagerControl.frame.origin.x = (UIScreen().bounds.width) / 2.0
        
        
        
        pagerControl?.setFillColor(Utils.hexStringToUIColor(hex: "#cccccc").withAlphaComponent(0.5), for: .normal)
        pagerControl?.setFillColor(.white, for: .selected)
        pagerControl?.itemSpacing = 10
        pagerControl?.setPath(UIBezierPath(rect: CGRect(x: 0, y: 0, width: 10, height: 2)), for: .normal)
        pagerControl?.setPath(UIBezierPath(rect: CGRect(x: 0, y: 0, width: 10, height: 2)), for: .selected)
        pagerControl?.contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
    }
    
    public func initialize() {
        if pagerView == nil {
            makeViews()
        }
    
    }
    
    public func update() {
        pagerView?.reloadData()
        self.pagerControl?.numberOfPages = self.ads.count
        pagerView?.layoutIfNeeded()
        if self.ads.count > 0 {
            pagerView?.scrollToItem(at: 0, animated: false)
        }
    }
    
}
