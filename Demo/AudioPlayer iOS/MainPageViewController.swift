//
//  CourseMainPageViewController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer
import QorumLogs

class CourseMainPageViewController: BaseUIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playingButton: UIButton!
    var extendFunctionMananger : ExtendFunctionMananger!
    var ads = [Advertise]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let screenWidth = UIScreen.mainScreen().bounds.height
        print("screenWidth = \(screenWidth)")
        var maxRows = 100
        if screenWidth < 667 {
            maxRows = 2
        }
        extendFunctionMananger = ExtendFunctionMananger(controller: self, showMaxRows: maxRows)
        
        
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
    
    
    let adImageWidth = UIScreen.mainScreen().bounds.width
    let adImageRatio : CGFloat = 0.3
}


extension CourseMainPageViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return extendFunctionMananger.getRowCount() + 1
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
            
            if row == extendFunctionMananger.getRowCount() {
                return makeAdvCell()
            } else {
                let cell = extendFunctionMananger.getFunctionCell(tableView, row: row)
                
                return cell
            }
        }
    }
    
    
    
    private func makeAdvCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("functionCell")!
        
        let imageWidth = adImageWidth
        let imageHeight = adImageWidth * adImageRatio
        
        let cellHeight = computeAdCellHeight()
        let x : CGFloat = 0
        var y =  (cellHeight - imageHeight)
        
        if y < 0 {
            y = 0
        }
        
        //print("cellWidth = \(imageWidth), cellHeight = \(cellHeight), imageHeight = \(imageHeight), x = \(x), y = \(y)")
        
        let scrollView = UIScrollView(frame: CGRect(x: x, y: y, width: imageWidth, height: imageHeight ))
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAdImageHandler))
        
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.userInteractionEnabled = true
        
        cell.addSubview(scrollView)
        //print("scrollView.superview = \(scrollView.superview)")
        scrollView.auk.settings.pageControl.backgroundColor =  UIColor.grayColor().colorWithAlphaComponent(0)
        
        scrollView.auk.settings.contentMode = UIViewContentMode.ScaleToFill
        
        BasicService().sendRequest(ServiceConfiguration.GET_ADS, request: GetAdsRequest()) {
            (resp : GetAdsResponse) -> Void in
            if resp.status != 0 {
                print("ERROR: ads return status is \(resp.status)")
                return
            }
            
            self.ads = resp.ads
            for ad in self.ads {
                // Show remote image
                QL1("ad.imageUrl = \(ad.imageUrl)")
                scrollView.auk.show(url: ad.imageUrl)
                
            }
            scrollView.auk.startAutoScroll(delaySeconds: 3)
        }
        
        
        return cell
    }

    func tapAdImageHandler(sender: UITapGestureRecognizer? = nil) {
        let scrollView = sender?.view as! UIScrollView
        print(scrollView.auk.currentPageIndex)
        let index = scrollView.auk.currentPageIndex
        if index != nil {
            let params : [String: String] = ["url": ads[index!].clickUrl, "title": ads[index!].title]
            performSegueWithIdentifier("loadWebPageSegue", sender: params)
        }
    }

    private func computeAdCellHeight() -> CGFloat {
        let section1Height = 3 * 53
        let section2Height = extendFunctionMananger.getRowCount() * 79
        let total = section1Height + section2Height + 3 + 65 + 49 - 1
        var height = UIScreen.mainScreen().bounds.height - CGFloat(total)
        
        if height < adImageWidth * adImageRatio  {
            height = adImageWidth * adImageRatio + 10
        }
        return height
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        if section == 1 {
            if row == extendFunctionMananger.getRowCount() {
                return computeAdCellHeight()
            } else {
                return 79
            }
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
                performSegueWithIdentifier("beforeCourseSegue", sender: CourseType.Live.rawValue)
                break
            case 1:
                performSegueWithIdentifier("beforeCourseSegue", sender: CourseType.Vip.rawValue)
                break
            case 2:
                performSegueWithIdentifier("beforeCourseSegue", sender: CourseType.Common.rawValue)
                break
            default:
                break
            }
        }
    }

}
