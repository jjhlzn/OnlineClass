//
//  LTHeaderView.swift
//  LTScrollView
//
//  Created by 高刘通 on 2018/2/3.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//
//  如有疑问，欢迎联系本人QQ: 1282990794
//
//  ScrollView嵌套ScrolloView解决方案（初级、进阶)， 支持OC/Swift
//
//  github地址: https://github.com/gltwy/LTScrollView
//
//  clone地址:  https://github.com/gltwy/LTScrollView.git
//

import UIKit
import KDEAudioPlayer
import QorumLogs

class LTHeaderView: UIView  {
    var  headerView : PlayerHeaderView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //let headerView = PlayerHeaderView(frame: frame)
        //headerView.audioPlayer = Utils.getAudioPlayer()
        //headerView.initalize()
        //headerView.audioPlayer?.delegate = self
        //addSubview(headerView)
        //QL1("delegate : \(String(describing: headerView.audioPlayer?.delegate))")
    }
    
    func initialize() {
        headerView.initalize()
        addSubview(headerView)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    
    //MARK: 暂用，待优化。
    /*
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for tempView in self.subviews {
            if tempView.isKind(of: UILabel.self) {
                let button = tempView as! UILabel
                let newPoint = self.convert(point, to: button)
                if button.bounds.contains(newPoint) {
                    return true
                }
            }
        }
        return false
    } */
    
    
}

