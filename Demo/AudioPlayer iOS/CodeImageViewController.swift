//
//  CodeImageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/8.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import Kingfisher

class CodeImageViewController: BaseUIViewController {
    
    
    @IBOutlet weak var codeImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginUser = LoginUserStore().getLoginUser()!
        
        if loginUser.codeImageUrl != nil {
            codeImageView.kf_setImageWithURL(NSURL(string: loginUser.codeImageUrl!)!)
        }
    }

}
