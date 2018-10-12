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
    
    var beforeCourses = [Course]()
    var disappeared = false
    
    private lazy var tableView: UITableView = {
        print(UIScreen.main.bounds.height)
        let H: CGFloat = UIDevice().isX() ? (view.bounds.height - 38) : view.bounds.height  - 38
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
        
        loadBeforeCourses()
    }
    
    func loadBeforeCourses() {
        let req = GetCourseInfoRequest()
        let song = Utils.getCurrentSong()
        req.id = song.id
        _ = BasicService().sendRequest(url: ServiceConfiguration.GET_COURSEINFO, request: req) {
            (resp: GetCourseInfoResponse) -> Void in
            if self.disappeared {
                return
            }
            if resp.course != nil {
                self.beforeCourses = (resp.course?.beforeCourses)!
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disappeared = true
    }
    
}

extension BeforeCourseVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + beforeCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            let cell : BeforeCourseHeaderCell = cellWithTableView(tableView)
            return cell
        } else {
            let cell : BeforeCourseCell = cellWithTableView(tableView)
            cell.course = beforeCourses[row - 1]
            cell.update()
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
        //print("点击了第\(indexPath.row + 1)行")
    }

}
