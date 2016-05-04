//
//  CourseMainPageViewController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class CourseMainPageViewController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
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
                cell.courseTypeName.text = "直播信用卡秘诀！"
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
            cell.secondImageView.image = UIImage(named: "visa")
            cell.firstLabel.text = "一键提额"
            cell.secondLabel.text = "一键办卡"
            return cell
        }
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "beforeCourseSegue" {
            let dest = segue.destinationViewController as! AlbumListController
            
            dest.courseType = CourseType(rawValue: sender as! String)!
        }
    }

    
}
