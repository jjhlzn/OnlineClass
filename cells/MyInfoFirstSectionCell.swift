//
//  MyInfoFirstSectionCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/17.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs

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
        if UserProfilePhotoStore().get() == nil {
            QL1("userName = \(loginUser.userName)")
            let profilePhotoUrl = ServiceConfiguration.GET_PROFILE_IMAGE + "?userid=" + loginUserStore.getLoginUser()!.userName!
            QL1("userimageurl = \(profilePhotoUrl)")
            
            headerImageView.kf.setImage(with: URL(string: profilePhotoUrl))
            
            /*
             cell.userImage.kf_setImageWithURL(NSURL(string: profilePhotoUrl)!,
             placeholderImage: nil,
             optionsInfo: nil,
             progressBlock: { (receivedSize, totalSize) -> () in
             //print("Download Progress: \(receivedSize)/\(totalSize)")
             },
             completionHandler: { (image, error, cacheType, imageURL) -> () in
             if image != nil {
             UserProfilePhotoStore().saveOrUpdate(image!)
             }
             }) */
            
        } else {
            headerImageView.image = UserProfilePhotoStore().get()
        }
        
        
        headerImageView.becomeCircle()
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(userImageTapped))
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(tapGestureRecognizer)

        
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
        
        myBossLabel.text = loginUser.boss!

    }
    
    @objc func userImageTapped(img: AnyObject) {
        controller?.performSegue(withIdentifier: "setProfilePhotoSegue", sender: nil)
    }

}
