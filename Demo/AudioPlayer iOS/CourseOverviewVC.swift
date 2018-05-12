//
//  CourseOverviewVC.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/11.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import LTScrollView

class CourseOverviewVC: UIViewController, LTTableViewProtocal {

    private lazy var tableView: UITableView = {
        print(UIScreen.main.bounds.height)
        let H: CGFloat = glt_iphoneX ? (view.bounds.height - 64 - 24 - 34) : view.bounds.height  - 64
        let tableView = tableViewConfig(CGRect(x: 0, y: 0, width: view.bounds.width, height: H), self, self, nil)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        glt_scrollView = tableView
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        tableView.estimatedRowHeight = 0
        self.tableView.register(UINib(nibName:"CourseOverviewHeaderCell", bundle:nil),forCellReuseIdentifier:"CourseOverviewHeaderCell")
        self.tableView.register(UINib(nibName:"CourseOverviewCell", bundle:nil),forCellReuseIdentifier:"CourseOverviewCell")
        self.tableView.register(UINib(nibName:"NewCommentHeaderCell", bundle:nil),forCellReuseIdentifier:"NewCommentHeaderCell")
        self.tableView.register(UINib(nibName:"NewCommentCell", bundle:nil),forCellReuseIdentifier:"NewCommentCell")
    }
    
}

extension CourseOverviewVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            let cell : CourseOverviewHeaderCell = cellWithTableView(tableView)
            return cell
        } else if row == 1 {
            let cell : CourseOverviewCell = cellWithTableView(tableView) 
            return cell
        } else if row == 2 {
            let cell : NewCommentHeaderCell = cellWithTableView(tableView)
            return cell
        } else {
            let cell : NewCommentCell = cellWithTableView(tableView)
            makeRoundImage(cell.headImageView)
            let row = indexPath.row
            
            var frame = cell.commentLabel.frame;
            cell.commentLabel.numberOfLines = 0
            cell.commentLabel.sizeToFit()
            frame.size.height = cell.commentLabel.frame.size.height;
            cell.commentLabel.frame = frame;
            var height = cell.commentLabel.bounds.height
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 0 {
            return 56
        } else if row == 1 {
            let cell : CourseOverviewCell = cellWithTableView(tableView)
            let row = indexPath.row

            var frame = cell.overview.frame;
            cell.overview.numberOfLines = 0
            cell.overview.sizeToFit()
            frame.size.height = cell.overview.frame.size.height;
            cell.overview.frame = frame;
            var height = cell.overview.bounds.height

            return  height + 15

        } else if row == 2 {
            return 56
        } else {
            let cell : NewCommentCell = cellWithTableView(tableView)
            cell.timeLabel.text = "测试"
            makeRoundImage(cell.headImageView)
            let row = indexPath.row
            
            var frame = cell.commentLabel.frame;
            cell.commentLabel.numberOfLines = 0
            cell.commentLabel.sizeToFit()
            frame.size.height = cell.commentLabel.frame.size.height;
            cell.commentLabel.frame = frame;
            var height = cell.commentLabel.bounds.height
            
            return  height + 50 + 20
        }
    }
    
    func makeRoundImage(_ image: UIImageView) {
        image.layer.borderWidth = 0.1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.lightGray.cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("点击了第\(indexPath.row + 1)行")
    }
    
}
