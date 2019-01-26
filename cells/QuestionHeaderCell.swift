//
//  QuestionHeaderCellTableViewCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/9/7.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class QuestionHeaderCell: UITableViewCell {
    
    var viewController : BaseUIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func viewAllPressed(_ sender: Any) {
        DispatchQueue.main.async { () -> Void in
            self.viewController!.performSegue(withIdentifier: "allQuestionsSegue", sender: nil)
        }
    }
}
