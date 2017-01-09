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
    
    var footerImageInterWidth = 2
}


extension CourseMainPageViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getRowCount()
    }
    
    private func getRowCount() -> Int {
        return 1 + extendFunctionMananger.getRowCount() + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        if row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("mainpageHeaderAdvCell") as! HeaderAdvCell
            return cell

        } else if row == getRowCount() - 1 {
             return makeAdvCell()
        } else {
            let cell = extendFunctionMananger.getFunctionCell(tableView, row: row - 1)
            return cell

        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        if row == 0 {
            return getHeaderAdvHeight()
        } else if row == getRowCount() - 1 {
            return computeAdCellHeight()
        } else {
            return extendFunctionMananger.cellHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let section = indexPath.section
        
        
        /*
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
         }*/
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
    
    
    
    var footerImageWidth:CGFloat {
        get {
            let screenWidth = UIScreen.mainScreen().bounds.width;
            let width = (screenWidth - CGFloat(footerImageInterWidth * 3)) / 4
            QL1("footer width: \(width)")
            return width
        }
    }
    
    var footerImageHeight:CGFloat {
        get {
            return footerImageWidth * 1418 / 1380
        }
    }
    
    private func makeImage(index: Int) -> UIImageView {
        let x = CGFloat(index) * footerImageWidth + CGFloat(index * footerImageInterWidth);
        var y =  computeAdCellHeight() - footerImageHeight
    
        if y < 0 {
            y = 0
        }

        let imageView = UIImageView(frame: CGRectMake(x, y, footerImageWidth, footerImageHeight))
        imageView.image = UIImage(named: "footer_ditu")
        imageView.tag = index
        
        return imageView
    }
    
    private func makeAdvCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("functionCell")!
        cell.addSubview(makeImage(0))
        cell.addSubview(makeImage(1))
        cell.addSubview(makeImage(2))
        cell.addSubview(makeImage(3))
        return cell
    }


    private func computeAdCellHeight() -> CGFloat {
        let section1Height = getHeaderAdvHeight()
        let section2Height = CGFloat(extendFunctionMananger.getRowCount()) * extendFunctionMananger.cellHeight
        let total = section1Height + section2Height + 3 + 65 + 49 - 3
        var height = UIScreen.mainScreen().bounds.height - CGFloat(total)
        
        if height < adImageWidth * adImageRatio  {
            height = adImageWidth * adImageRatio + 10
        }
        return height
    }
    
    
    private func getHeaderAdvHeight() -> CGFloat {
        let screenWidth = UIScreen.mainScreen().bounds.width
        return screenWidth * 140 / 320
    }

    


}
