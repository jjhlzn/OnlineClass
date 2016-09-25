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
import Auk

class CourseMainPageViewController: BaseUIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playingButton: UIButton!
    var extendFunctionMananger : ExtendFunctionMananger!
    var ads = [Advertise]()
    var keyValueStore = KeyValueStore()

    
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
        extendFunctionMananger = ExtendFunctionMananger(controller: self, isNeedMore:  true, showMaxRows: maxRows)
        addPlayingButton(playingButton)

    }
    
    private func updateCellForDesc(resp: GetParameterInfoResponse, key: String, cell: CourseTypeCell) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePlayingButton(playingButton)
        
        let request = GetParameterInfoRequest()
        request.keys.append(GetParameterInfoResponse.LIVE_DESCRIPTION)
        BasicService().sendRequest(ServiceConfiguration.GET_PARAMETER_INFO, request: request) {
            (resp: GetParameterInfoResponse) -> Void in
            if resp.status != ServerResponseStatus.Success.rawValue {
                QL4(resp.errorMessage)
                return
            }
            
            //设置liveDescription
            let liveDescription = resp.getValue(GetParameterInfoResponse.LIVE_DESCRIPTION)
            self.keyValueStore.save(GetParameterInfoResponse.LIVE_DESCRIPTION, value: liveDescription)
            
            //设置LiveCourseName
            let liveName = resp.getValue(GetParameterInfoResponse.LIVE_COURSE_NAME)
            self.keyValueStore.save(GetParameterInfoResponse.LIVE_COURSE_NAME, value: liveName)
            let liveCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! CourseTypeCell
            liveCell.courseTypeName.text = liveName
            liveCell.courseDescription.text = liveDescription
            
            //设置payDescription
            let payDescription = resp.getValue(GetParameterInfoResponse.PAY_DESCRIPTION)
            self.keyValueStore.save(GetParameterInfoResponse.PAY_DESCRIPTION, value: payDescription)
            
            //设置PayCourseName
            let payCourseName = resp.getValue(GetParameterInfoResponse.PAY_COURSE_NAME)
            self.keyValueStore.save(GetParameterInfoResponse.PAY_COURSE_NAME, value: payCourseName)
            let payCourseCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! CourseTypeCell
            payCourseCell.courseTypeName.text = payCourseName
            payCourseCell.courseDescription.text = payDescription
            
            
            self.tableView.reloadData()
        }

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "beforeCourseSegue" {
            let dest = segue.destinationViewController as! AlbumListController
            
            dest.courseType = sender as! CourseType
        } 
        else if segue.identifier == "loadWebPageSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            
                       
            let params = sender as! [String: String]
            dest.url = NSURL(string: params["url"]!)
            
            dest.title = params["title"]
        } else if segue.identifier == "bugVipSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            dest.url = NSURL(string: ServiceLinkManager.MyAgentUrl)
            dest.title = "Vip购买"
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
            return 2
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
                cell.courseTypeName.text = keyValueStore.get(GetParameterInfoResponse.LIVE_COURSE_NAME, defaultValue: CourseType.LiveCourse.name)
                imageName = "liveAudio"
                cell.courseTypeImageView.image = UIImage(named: imageName)
                cell.courseDescription.text = KeyValueStore().get(GetParameterInfoResponse.LIVE_DESCRIPTION)
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("courseTypeCell") as! CourseTypeCell
                cell.courseTypeName.text = keyValueStore.get(GetParameterInfoResponse.PAY_COURSE_NAME, defaultValue: CourseType.PayCourse.name)

                imageName = "vipCourse"
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
    
    func tapAdImageHandler(sender: UITapGestureRecognizer? = nil) {
        let scrollView = sender?.view as! UIScrollView
        print(scrollView.auk.currentPageIndex)
        let index = scrollView.auk.currentPageIndex
        if index != nil {
            let params : [String: String] = ["url": ads[index!].clickUrl, "title": ads[index!].title]
            performSegueWithIdentifier("loadWebPageSegue", sender: params)
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
        
        //创建滚动广告
        let scrollView = UIScrollView(frame: CGRect(x: x, y: y, width: imageWidth, height: imageHeight ))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAdImageHandler))
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.userInteractionEnabled = true
        
        cell.addSubview(scrollView)
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


    private func computeAdCellHeight() -> CGFloat {
        let section1Height = 2 * 76
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
            return 76
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
                performSegueWithIdentifier("beforeCourseSegue", sender: CourseType.LiveCourse)
                break
            case 1:
                performSegueWithIdentifier("beforeCourseSegue", sender: CourseType.PayCourse)
                break
            default:
                break
            }
        }
    }

}
