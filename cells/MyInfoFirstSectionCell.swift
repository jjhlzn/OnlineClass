//
//  MyInfoFirstSectionCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/17.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs
import Kingfisher

class MyInfoFirstSectionCell: UITableViewCell {

    var controller : UIViewController?
    @IBOutlet weak var headerImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var myBossLabel: UILabel!
    
    @IBOutlet weak var agentLevelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        let loginUserStore = LoginUserStore()
        let loginUser : LoginUserEntity = loginUserStore.getLoginUser()!
        
        if LoginManager().isAnymousUser(loginUser) {
            nameLabel.text = "点击登陆"
            nameLabel.sizeToFit()
            agentLevelLabel.isHidden = true
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(goToLoginPage))
            headerImageView.isUserInteractionEnabled = true
            headerImageView.addGestureRecognizer(tapGestureRecognizer)
            
            let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action: #selector(goToLoginPage))
            nameLabel.isUserInteractionEnabled = true
            nameLabel.addGestureRecognizer(tapGestureRecognizer2)
            
        } else {
            agentLevelLabel.isHidden = false
            Utils.setUserHeadImageView(headerImageView, userId: loginUser.userName!)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(userImageTapped))
            headerImageView.isUserInteractionEnabled = true
            headerImageView.addGestureRecognizer(tapGestureRecognizer)
        
            nameLabel.isUserInteractionEnabled = false
            nameLabel.text = loginUser.name
            nameLabel.sizeToFit()
            
            agentLevelLabel.text = " \(loginUser.level!) "
            agentLevelLabel.sizeToFit()
            let frame = agentLevelLabel.frame
            let newFrame = CGRect(x: nameLabel.frame.maxX + 3, y: frame.minY, width: frame.width + 5, height: frame.height + 5)
            agentLevelLabel.frame = newFrame
            agentLevelLabel.layer.borderColor = agentLevelLabel.textColor.cgColor
            agentLevelLabel.layer.borderWidth = 0.5
            agentLevelLabel.layer.cornerRadius = 2
            agentLevelLabel.layer.masksToBounds = true
        }
    }
    
    @objc func userImageTapped(img: AnyObject) {
        DispatchQueue.main.async { () -> Void in
            self.controller?.performSegue(withIdentifier: "setProfilePhotoSegue", sender: nil)
        }
    }
    
    @objc func goToLoginPage() {
        LoginManager().goToLoginPage(controller!)
    }

}
