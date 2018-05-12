//
//  BeforeCourseVC.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/12.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import LTScrollView

class BeforeCourseVC: UIViewController, LTTableViewProtocal {

    private lazy var tableView: UITableView = {
        print(UIScreen.main.bounds.height)
        let H: CGFloat = glt_iphoneX ? (view.bounds.height - 64 - 24 - 34) : view.bounds.height  - 64
        let tableView = tableViewConfig(CGRect(x: 0, y: 0, width: view.bounds.width, height: H), self, self, nil)
        //tableView.separatorStyle = .none
        tableView.bounces = false
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
        
        self.tableView.register(UINib(nibName:"BeforeCourseHeaderCell", bundle:nil),forCellReuseIdentifier:"BeforeCourseHeaderCell")
        self.tableView.register(UINib(nibName:"BeforeCourseCell", bundle:nil),forCellReuseIdentifier:"BeforeCourseCell")
    }
    
}

extension BeforeCourseVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            let cell : BeforeCourseHeaderCell = cellWithTableView(tableView)
            return cell
        } else {
            let cell : BeforeCourseCell = cellWithTableView(tableView)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 0 {
            return 56
        } else {
            return  47
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("点击了第\(indexPath.row + 1)行")
    }

}
