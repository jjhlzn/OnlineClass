//
//  MyInfoSecondSectionCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/17.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class MyInfoSecondSectionCell: UITableViewCell {
    var controller : UIViewController?

    @IBOutlet weak var lineBorder1: UIView!
    @IBOutlet weak var lineBorder2: UIView!
    
    
    @IBOutlet weak var caifuTitle: UILabel!
    @IBOutlet weak var caifuLabel: UILabel!
    
    
    @IBOutlet weak var jifenTitle: UILabel!
    @IBOutlet weak var jifenLabel: UILabel!
    
    @IBOutlet weak var teamTitle: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    
    @IBOutlet weak var tixianBtn: UIButton!
     var keyValueStore = KeyValueStore()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        let frame1 = lineBorder1.frame
        let newFrame1 = CGRect(x: frame1.minX, y: frame1.minY, width: frame1.width, height: 0.5)
        lineBorder1.frame = newFrame1
        
        let frame2 = lineBorder2.frame
        let newFrame2 = CGRect(x: frame2.minX, y: frame2.minY, width: 0.5, height: frame2.height)
        lineBorder2.frame = frame2
        jifenLabel.text = keyValueStore.get(key: KeyValueStore.key_jifen, defaultValue: "0")
        caifuLabel.text = keyValueStore.get(key: KeyValueStore.key_chaifu, defaultValue: "0")
        teamLabel.text = keyValueStore.get(key: KeyValueStore.key_tuandui, defaultValue: "1人")
        tixianBtn.layer.borderWidth = 0.5
        tixianBtn.layer.cornerRadius = 3
        tixianBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        tixianBtn.addTarget(self, action: #selector(tixianBtnPressed), for: .touchUpInside)
        
        
        caifuLabel.isUserInteractionEnabled = true
        caifuTitle.isUserInteractionEnabled = true
        let cfGesture = UITapGestureRecognizer(target: self, action: #selector(caifuPressed))
        let cfGesture2 = UITapGestureRecognizer(target: self, action: #selector(caifuPressed))
        caifuLabel.addGestureRecognizer(cfGesture)
        caifuTitle.addGestureRecognizer(cfGesture2)
        
        
        jifenLabel.isUserInteractionEnabled = true
        jifenTitle.isUserInteractionEnabled = true
        let jifenGesture = UITapGestureRecognizer(target: self, action: #selector(jifenPressed))
        let jifenGesture2 = UITapGestureRecognizer(target: self, action: #selector(jifenPressed))
        jifenLabel.addGestureRecognizer(jifenGesture)
        jifenTitle.addGestureRecognizer(jifenGesture2)
        
        teamLabel.isUserInteractionEnabled = true
        teamTitle.isUserInteractionEnabled = true
        let teamGesture = UITapGestureRecognizer(target: self, action: #selector(tuanduiPressed))
        let teamGesture2 = UITapGestureRecognizer(target: self, action: #selector(tuanduiPressed))
        teamLabel.addGestureRecognizer(teamGesture)
        teamTitle.addGestureRecognizer(teamGesture2)
        
    }
    
    @objc func tixianBtnPressed() {
        if checkLogin() {
            return
        }
        
        var sender = [String:String]()
        sender["title"] = "提现"
        sender["url"] = ServiceLinkManager.MyExchangeUrl
        DispatchQueue.main.async { () -> Void in
            self.controller?.performSegue(withIdentifier: "webViewSegue", sender: sender)
        }
    }
    
    @objc func caifuPressed() {
        if checkLogin() {
            return
        }
        
        var sender = [String:String]()
        sender["title"] = "我的财富"
        sender["url"] = ServiceLinkManager.MyChaifuUrl
        DispatchQueue.main.async { () -> Void in
            self.controller?.performSegue(withIdentifier: "webViewSegue", sender: sender)
        }
    }

    @objc func jifenPressed() {
        if checkLogin() {
            return
        }
        
        var sender = [String:String]()
        sender["title"] = "我的积分"
        sender["url"] = ServiceLinkManager.MyJifenUrl
        DispatchQueue.main.async { () -> Void in
            self.controller?.performSegue(withIdentifier: "webViewSegue", sender: sender)
        }
    }

    @objc func tuanduiPressed() {
        if checkLogin() {
            return
        }
        
        var sender = [String:String]()
        sender["title"] = "我的团队"
        sender["url"] = ServiceLinkManager.MyTeamUrl
        DispatchQueue.main.async { () -> Void in
            self.controller?.performSegue(withIdentifier: "webViewSegue", sender: sender)
        }
    }
    
    func checkLogin() -> Bool {
        let loginUser = LoginUserStore().getLoginUser()!
        if LoginManager().isAnymousUser(loginUser) {
            LoginManager().checkLogin(controller!)
            return true
        }
        return false
    }
}
