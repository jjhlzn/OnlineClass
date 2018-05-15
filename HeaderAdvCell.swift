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
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "mainpage_cell")
            
        }
        
    }
    
    @IBOutlet weak var pagerControl: FSPageControl!  {
        didSet {
            self.pagerControl.numberOfPages = self.ads.count
            self.pagerControl.contentHorizontalAlignment = .right
            self.pagerControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            self.pagerControl.hidesForSinglePage = true
        
            pagerControl.backgroundColor = nil
            self.pagerControl.setFillColor(UIColor.lightGray, for: .normal)
            
            self.pagerControl.setFillColor(UIColor.white, for: .selected)
        }
    }
    
    @IBOutlet weak var yaoqingBtn: UIButton!
    @IBOutlet weak var toutiaoLabel: UILabel!
    
    public var ads : [Advertise] = [Advertise]()
    public var toutiao = Toutiao()
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return ads.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "mainpage_cell", at: index)
        cell.textLabel?.backgroundColor = nil
        cell.contentView.layer.shadowRadius = 0
        cell.imageView?.contentMode = .scaleToFill
        cell.imageView?.kf.setImage(with: URL(string: ads[index].imageUrl))
        cell.textLabel?.text = String("")
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
            QL1("FSPagerView index = " + String(index) + " selected")
        var sender = [String:String]()
        sender["url"] = self.ads[index].clickUrl
        sender["title"] = self.ads[index].title
        self.controller?.performSegue(withIdentifier: "loadWebPageSegue", sender: sender)
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        self.pagerControl.currentPage = index
    }
    
    public func initialize() {
        pagerView.automaticSlidingInterval = 3.0
        pagerView.backgroundColor = UIColor.white
        pagerView.isInfinite = true
        pagerView.dataSource = self
        pagerView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToutiaoLabel))
        toutiaoLabel.isUserInteractionEnabled = true
        toutiaoLabel.addGestureRecognizer(tap)
        
        yaoqingBtn.addTarget(self, action: #selector(yaoQingPressed), for: .touchUpInside)
    }
    
    @objc func tapToutiaoLabel() {
        var sender = [String:String]()
        sender["title"] = toutiao.title
        sender["url"] = toutiao.clickUrl
        controller?.performSegue(withIdentifier: "loadWebPageSegue", sender: sender)
    }
    @objc func yaoQingPressed() {
        controller?.performSegue(withIdentifier: "codeImageSegue", sender: nil)
    }
    
    public func update() {
        pagerView.reloadData()
        self.pagerControl.numberOfPages = self.ads.count
        toutiaoLabel.text = toutiao.content
    }
}
