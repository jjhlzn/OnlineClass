//
//  CourseMainPageViewController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer

class CourseMainPageViewController: BaseUIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playingButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        addPlayingButton(playingButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePlayingButton(playingButton)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "beforeCourseSegue" {
            let dest = segue.destinationViewController as! AlbumListController
            
            dest.courseType = CourseType(rawValue: sender as! String)!
        } else if segue.identifier == "loadWebPageSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            let params = sender as! [String: String]
            dest.url = NSURL(string: params["url"]!)
            let backItem = UIBarButtonItem()
            backItem.title = "关闭"
            navigationItem.backBarButtonItem = backItem
            dest.title = params["title"]
        }
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        let audioItem = getAudioPlayer().currentItem
        if audioItem == nil {
            print("audioItem is nil")
            return
        }
        updatePlayingButton(playingButton)
    }
    
}


extension CourseMainPageViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 1
        }
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let row = indexPath.row
        var imageName = ""
        
        if indexPath.section == 0 {
            switch row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("courseTypeCell") as! CourseTypeCell
                cell.courseTypeName.text = "直播课程！"
                imageName = "liveAudio"
                cell.courseTypeImageView.image = UIImage(named: imageName)
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("courseTypeCell") as! CourseTypeCell
                cell.courseTypeName.text  = "往期课程内容"
                imageName = "beforeCourse"
                cell.courseTypeImageView.image = UIImage(named: imageName)
                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("courseTypeCell") as! CourseTypeCell
                cell.courseTypeName.text = "VIP课堂"
                imageName = "vipCourse"
                cell.courseTypeImageView.image = UIImage(named: imageName)
                return cell
                
                
                
            default:
                return tableView.dequeueReusableCellWithIdentifier("courseTypeCell") as! CourseTypeCell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("functionCell") as! FunctionCell
            cell.firstImageView.image = UIImage(named: "up")
            let upTap = UITapGestureRecognizer(target: self, action: #selector(upImageHandle))
            cell.firstImageView.addGestureRecognizer(upTap)
            cell.firstImageView.userInteractionEnabled = true
            cell.firstLabel.text = "一键提额"
            
            cell.secondImageView.image = UIImage(named: "visa")
            let cardTap = UITapGestureRecognizer(target: self, action: #selector(cardImageHandle))
            cell.secondImageView.addGestureRecognizer(cardTap)
            cell.secondImageView.userInteractionEnabled = true
            cell.secondLabel.text = "一键办卡"
            
            return cell
        }
        
    }
    
    func upImageHandle() {
        let params : [String: String] = ["url": "http://www.baidu.com", "title": "一键提额"]
        performSegueWithIdentifier("loadWebPageSegue", sender: params)
    
    }
    
    func cardImageHandle() {
        let params : [String: String] = ["url": "http://www.weibo.com", "title": "一键办卡"]
        performSegueWithIdentifier("loadWebPageSegue", sender: params)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 1 {
            return 112
        } else {
            return 53
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.selectionStyle = .None
        let section = indexPath.section
        if section == 1 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.selectionStyle = .None
        } else {
            let row = indexPath.row
            switch row {
            case 0:
                performSegueWithIdentifier("beforeCourseSegue", sender: CourseType.Live.rawValue)
                break
            case 1:
                performSegueWithIdentifier("beforeCourseSegue", sender: CourseType.Common.rawValue)
                break
            case 2:
                performSegueWithIdentifier("beforeCourseSegue", sender: CourseType.Vip.rawValue)
                break
            default:
                break
            }
        }
    }

}
