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
    @IBOutlet weak var caifuLabel: UILabel!
    
    @IBOutlet weak var jifenLabel: UILabel!
    
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
    }
    
    @objc func tixianBtnPressed() {
        var sender = [String:String]()
        sender["title"] = "提现"
        sender["url"] = ServiceLinkManager.MyExchangeUrl
        controller?.performSegue(withIdentifier: "webViewSegue", sender: sender)
    }

}
