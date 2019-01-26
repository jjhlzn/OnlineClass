//
//  MyViewController.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/9/17.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import SnapKit
import QorumLogs

class MyViewController: UIViewController {
    
    lazy var box = UIView()
    
    @objc func tapBox() {
        QL1("tap Box called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        box.backgroundColor = UIColor.red
        self.view.addSubview(box)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapBox))
        box.isUserInteractionEnabled = true
        box.addGestureRecognizer(tap)
        /*
        box.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(50)
            make.center.equalTo(self.view)
        } */
        box.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(box.superview!).inset(UIEdgeInsetsMake(20, 20, 20, 20))
        }
    }
    
}
