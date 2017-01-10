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
    var freshHeaderAdvTimer: NSTimer!
    var footerAdvs = [FooterAdv]()
    var headerAdv: HeaderAdv?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let screenHeight = UIScreen.mainScreen().bounds.height
        var maxRows = 3
        if screenHeight < 568 {  //568
            maxRows = 2
        }
        extendFunctionMananger = ExtendFunctionMananger(controller: self, isNeedMore:  true, showMaxRows: maxRows)
        addPlayingButton(playingButton)
    }
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updatePlayingButton(playingButton)
        loadHeaderAdv()
        loadFooterAdvs()
        createTimer()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        freshHeaderAdvTimer.invalidate()
    }
    
    private func createTimer() {
        freshHeaderAdvTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self,
                                                                selector: #selector(loadHeaderAdv), userInfo: nil, repeats: true)
    }
    

    func loadHeaderAdv() {
        BasicService().sendRequest(ServiceConfiguration.GET_HEADER_ADV, request: GetHeaderAdvRequest()) {
            (resp: GetHeaderAdvResponse) -> Void in
            if resp.status != ServerResponseStatus.Success.rawValue {
                QL4("server return error: \(resp.errorMessage!)")
                return
            }
            
            if resp.headerAdv != nil {
                let headerCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! HeaderAdvCell

                self.headerAdv = resp.headerAdv
                if let imageUrl = NSURL(string: (resp.headerAdv?.imageUrl)!) {
                    headerCell.advImage.kf_setImageWithURL(imageUrl)
                }
            }
        }
    }
    
    func loadFooterAdvs() {
        BasicService().sendRequest(ServiceConfiguration.GET_FOOTER_ADV, request: GetFooterAdvsRequest() ) {
            (resp: GetFooterAdvsResponse) -> Void in
            if resp.status != ServerResponseStatus.Success.rawValue {
                QL4("server return error: \(resp.errorMessage!)")
                return
            }
            if resp.advList.count == 4 {
                
                self.footerAdvs = resp.advList
                self.tableView.reloadData()
            }
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
            return
        }
        updatePlayingButton(playingButton)
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        performSegueWithIdentifier("searchSegue", sender: nil)
    }
    
    
    
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

        let row = indexPath.row
        if row == 0 {
            if headerAdv != nil {
                if (headerAdv?.type)! == HeaderAdv.Type_Song {
                    performSegueWithIdentifier("beforeCourseSegue", sender: CourseType.LiveCourse)
                } else {
                    print()
                }
            }
        }
    }
    
    func tapAdImageHandler(sender: UITapGestureRecognizer? = nil) {
        let scrollView = sender?.view as! UIScrollView
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
            return width
        }
    }
    
    var footerImageHeight:CGFloat {
        get {
            return footerImageWidth * 1418 / 1380
        }
    }
    
    func footerAdvImageHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        if self.footerAdvs.count != 4 {
            return
        }
        let footerAdv = self.footerAdvs[index!]
        let params : [String: String] = ["url": footerAdv.url, "title": footerAdv.title]
        performSegueWithIdentifier("loadWebPageSegue", sender: params)
    }
    
    private func makeImage(index: Int, adv: FooterAdv) -> UIImageView {
        let x = CGFloat(index) * footerImageWidth + CGFloat(index * footerImageInterWidth);
        var y =  computeAdCellHeight() - footerImageHeight
        
        if y < 0 {
            y = 0
        }
       // y = 0
        
        QL1("image: x=\(x), y=\(y)")

        let imageView = UIImageView(frame: CGRectMake(x, y, footerImageWidth, footerImageHeight))
        imageView.tag = index
        if adv.imageUrl != "" {
            if let imageUrl = NSURL(string: adv.imageUrl) {
                QL1("imageUrl: \(adv.imageUrl)")
                imageView.kf_setImageWithURL(imageUrl)
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(footerAdvImageHandler) ))
                imageView.userInteractionEnabled = true

            }
        } else {
            imageView.image = UIImage(named: "footer_ditu")
        }
        
        return imageView
    }
    
    private func makeAdvCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("footerAdvCell") as! FooterAdvCell
        if footerAdvs.count != 4 {
            footerAdvs = [FooterAdv]()
            footerAdvs.append(FooterAdv())
            footerAdvs.append(FooterAdv())
            footerAdvs.append(FooterAdv())
            footerAdvs.append(FooterAdv())
        }
        var i = 0
        footerAdvs.forEach() {
            (adv: FooterAdv) -> Void in
            cell.addSubview(makeImage(i, adv: adv))
            i = i + 1
        }
        return cell
    }


    private func computeAdCellHeight() -> CGFloat {
        let section1Height = getHeaderAdvHeight()
        let section2Height = CGFloat(extendFunctionMananger.getRowCount()) * extendFunctionMananger.cellHeight
        let total = section1Height + section2Height + 3 + 65 + 49 - 3
        var height = UIScreen.mainScreen().bounds.height - CGFloat(total)
        
        if height < footerImageHeight  {
            height = footerImageHeight
        }
        return height
    }
    
    
    private func getHeaderAdvHeight() -> CGFloat {
        let screenWidth = UIScreen.mainScreen().bounds.width
        return screenWidth * 140 / 320
    }

    


}
