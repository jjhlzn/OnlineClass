//
//  CourseOverviewVC.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/11.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import LTScrollView
import KDEAudioPlayer
import QorumLogs

class CourseOverviewVC: UIViewController, LTTableViewProtocal, LiveCommentDelegate {

    var song : LiveSong?
    var comments = [Comment]()
    var hasBottomBar : Bool = true
    
    private lazy var tableView: UITableView = {
        //print(UIScreen.main.bounds.height)
        var H: CGFloat = view.bounds.height  - 38
        if hasBottomBar {
            H = view.bounds.height - Utils.getTabHeight(controller: self) - 38
            if UIDevice().isX() {
                H = H - 24
            }
        } else {
            if UIDevice().isX() {
                H = H - 24
            }
        }
        let tableView = tableViewConfig(CGRect(x: 0, y: 0, width: view.bounds.width, height: H), self, self, nil)
        tableView.separatorStyle = .none
        tableView.bounces = false
        return tableView
    }()
    
    
    public func refresh() {
        loadComments()
        self.tableView.reloadData()
        
    }
    
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
        
        self.tableView.register(UINib(nibName:"CourseOverviewHeaderCell", bundle:nil),forCellReuseIdentifier:"CourseOverviewHeaderCell")
        self.tableView.register(UINib(nibName:"CourseOverviewCell", bundle:nil),forCellReuseIdentifier:"CourseOverviewCell")
        self.tableView.register(UINib(nibName:"NewCommentHeaderCell", bundle:nil),forCellReuseIdentifier:"NewCommentHeaderCell")
        self.tableView.register(UINib(nibName:"NewCommentCell", bundle:nil),forCellReuseIdentifier:"NewCommentCell")
        
        if song == nil {
            return
        } else {
            loadComments()
        }
    }
    
    var lastId = "-1"
    var isUpdateChat = false
    func loadComments() {
        let request = GetSongLiveCommentsRequest(song: song!, lastId: "-1")
        BasicService().sendRequest(url: ServiceConfiguration.GET_SONG_LIVE_COMMENTS, request: request) {
                (resp: GetSongLiveCommentsResponse) -> Void in
            
                if resp.comments.count > 0 {
                    self.lastId = resp.comments[0].id!
                }
                self.comments = resp.comments

                self.tableView.reloadData()
                QL3("table height = \(self.tableView.frame.height)")
        }
    }
    
    //comments是的长度总是为1
    func afterSendLiveComment(comments: [Comment]) {
        if comments.count > 0 {
            self.lastId = comments[0].id!
        }
        self.comments.insert(comments[0], at: 0)
        if self.comments.count > 9 {
            self.comments = Array(self.comments[0...8])
        }
        
        var indexs = [IndexPath]()
        for i in 0...comments.count {
            indexs.append(IndexPath(row: 3 + i, section: 0))
        }
        self.tableView.reloadRows(at: indexs, with: .none)
        QL3("table height = \(tableView.frame.height)")
    }
    
    
    func getLastCommentId() -> String {
        return lastId
    }
    
    func setUpdateChatFlag(isUpdateFlag: Bool) {
        self.isUpdateChat = isUpdateFlag
    }
}

extension CourseOverviewVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if song == nil {
            return 0
        }
        
        let count = 2 + 1 + comments.count
        QL3("comments.count = \(comments.count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        QL1("row = \(row)")
        if row == 0 {
            let cell : CourseOverviewHeaderCell = cellWithTableView(tableView)
            cell.song = song
            cell.update()
            return cell
        } else if row == 1 {
            let cell : CourseOverviewCell = cellWithTableView(tableView)
            cell.song = song
            cell.update()
            return cell
        } else if row == 2 {
            let cell : NewCommentHeaderCell = cellWithTableView(tableView)
            
            return cell
        } else {
            let cell : NewCommentCell = cellWithTableView(tableView)
            let row = indexPath.row
            let comment = comments[row - 3]
            cell.comment = comment
            cell.update()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 0 {
            return 56
        } else if row == 1 {
            let cell : CourseOverviewCell = cellWithTableView(tableView)
            cell.overview.text = song!.introduction
            /*
            var frame = cell.overview.frame;
            cell.overview.numberOfLines = 0
            cell.overview.sizeToFit()
            frame.size.height = cell.overview.frame.size.height;
            cell.overview.frame = frame; */
            
            cell.updateConstraints()
            let height =  cell.overview.frame.height

            return height

        } else if row == 2 {
            return 56
        } else {
            let cell : NewCommentCell = cellWithTableView(tableView)
            //cell.timeLabel.text = "测试"
            //makeRoundImage(cell.headImageView)
            let row = indexPath.row
            let comment = comments[row - 3]
            cell.comment = comment
       
            cell.nameLabel.text = comment.userId
            cell.timeLabel.text = comment.time
            cell.commentLabel.text = comment.content.emojiUnescapedString
            var frame = cell.commentLabel.frame;
            cell.commentLabel.numberOfLines = 0
            cell.commentLabel.sizeToFit()
            frame.size.height = cell.commentLabel.frame.size.height;
            cell.commentLabel.frame = frame;
            var height = 50 + cell.commentLabel.bounds.height + 28
            
            if height < 85 {
                height = 85
            }
            
            //QL1("content = \(comment.content.emojiUnescapedString), height = \(height)")
            //NSLog("row = \(row), height = \(heightCache[comment.content])" )
            return  height
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
        //print("点击了第\(indexPath.row + 1)行")
    }
    
}
