//
//  PosCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/9/8.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import Kingfisher
import QorumLogs

class PosCell: UITableViewCell {
    @IBOutlet weak var posImage: UIImageView!
    var pos : Pos?
    var viewController : UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @objc func tapImage() {
        QL1("tap image")
        var params = [String:String]()
        
        params["title"] = pos!.title
        params["url"] = pos!.clickUrl
        DispatchQueue.main.async { () -> Void in
            self.viewController?.performSegue(withIdentifier: "loadWebPageSegue", sender: params)
        }
       
    }

    func update() {
        QL1(pos!.imageUrl)
        posImage.kf.setImage(with: URL(string: (pos?.imageUrl)!))
        
        posImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImage)))
        posImage.isUserInteractionEnabled = true
    }

}
