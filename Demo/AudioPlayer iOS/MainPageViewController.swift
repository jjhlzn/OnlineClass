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
    var extendFunctionMananger : ExtendFunctionMananger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        extendFunctionMananger = ExtendFunctionMananger(controller: self)
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
        } else if segue.identifier == "liveCourseSegue" {
            let dest = segue.destinationViewController as! LiveAlbumListController
            
            dest.courseType = CourseType(rawValue: sender as! String)!
        }
        else if segue.identifier == "loadWebPageSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            
                       
            let params = sender as! [String: String]
            dest.url = NSURL(string: params["url"]!)
            
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
    
    @IBAction func searchPressed(sender: AnyObject) {
        performSegueWithIdentifier("searchSegue", sender: nil)
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
            return extendFunctionMananger.getRowCount()
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
                cell.courseTypeName.text = "VIP课堂"
                imageName = "vipCourse"
                cell.courseTypeImageView.image = UIImage(named: imageName)
                return cell

                
            case 2:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("courseTypeCell") as! CourseTypeCell
                cell.courseTypeName.text  = "往期课程内容"
                imageName = "beforeCourse"
                cell.courseTypeImageView.image = UIImage(named: imageName)
                return cell
                
                
                
            default:
                return tableView.dequeueReusableCellWithIdentifier("courseTypeCell") as! CourseTypeCell
            }
        } else {
            let cell = extendFunctionMananger.getFunctionCell(tableView, row: row)
            
            return cell
        }
    }
    

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 1 {
            return 79
        } else {
            return 53
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let section = indexPath.section
        if section == 1 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.selectionStyle = .None
        } else {
            let row = indexPath.row
            switch row {
            case 0:
                performSegueWithIdentifier("liveCourseSegue", sender: CourseType.Live.rawValue)
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
