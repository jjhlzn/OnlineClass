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

class LTHeaderView: UIView {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "点击响应事件"
        label.textColor = UIColor.white
        label.frame.origin.y = 30
        label.frame.origin.x = 50
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(_:))))
        label.backgroundColor = UIColor.gray
        label.sizeToFit()
        return label
    }()
    
    

    
    @objc private func tapLabel(_ gesture: UITapGestureRecognizer)  {
        print("tapLabel☄")
    }
    
    func getAudioPlayer() -> AudioPlayer {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.audioPlayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        /*
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: frame.height - 40))
        imageView.image = UIImage(named: "sample")
        backgroundColor = UIColor.white */
        
        let headerView = PlayerHeaderView(frame: frame)
        headerView.audioPlayer = getAudioPlayer()
        headerView.initalize()
        addSubview(headerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 暂用，待优化。
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
    }
}

