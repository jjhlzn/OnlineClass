//
//  LaunchViewController.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/6.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet weak var logView: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomConstraint.constant = 0
    }
}
