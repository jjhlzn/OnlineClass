//
//  MyInfoThirdSectionCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/17.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class MyInfoThirdSectionCell: UITableViewCell {

    var keyValueStore = KeyValueStore()
    var controller : UIViewController?
    
    @IBOutlet weak var vipEndDateLabel: UILabel!
    @IBOutlet weak var agentLabel: UILabel!
    @IBOutlet weak var buyVipBtn: UIButton!
    
    @IBOutlet weak var levelUpgradeBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func update() {
        let vipEndDate = keyValueStore.get(key: KeyValueStore.key_vipenddate, defaultValue: "")
        let loginStore = LoginUserStore()
        let loginUser = loginStore.getLoginUser()!
        if vipEndDate == "" {
            vipEndDateLabel.text = "无"
            buyVipBtn.setTitle("购买", for: .normal)
        } else {
            vipEndDateLabel.text = vipEndDate
            buyVipBtn.setTitle("续费", for: .normal)
        }
        
        agentLabel.text = loginUser.level!
        
        buyVipBtn.addTarget(self, action: #selector(buyVipPressed), for: .touchUpInside)
        levelUpgradeBtn.addTarget(self, action: #selector(agentLevelPressed), for: .touchUpInside)
    }
    
    @objc  func buyVipPressed() {
        var sender = [String:String]()
        sender["title"] = "VIP会员"
        sender["url"] = ServiceLinkManager.ShenqingUrl
        controller?.performSegue(withIdentifier: "webViewSegue", sender: sender)
    }
    
    @objc func agentLevelPressed() {
        var sender = [String:String]()
        sender["title"] = "升级"
        sender["url"] = ServiceLinkManager.ShenqingUrl
        controller?.performSegue(withIdentifier: "webViewSegue", sender: sender)
    }
}
