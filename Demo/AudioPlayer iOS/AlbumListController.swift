//
//  AlbumListController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer

class AlbumListController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate, PagableControllerDelegate {
    
    @IBOutlet weak var playingButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    var pagableController = PagableController<Album>()
    var courseType : CourseType = CourseType.Common
    
    var extendFunctionManager : ExtendFunctionMananger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        addPlayingButton(playingButton)
        
        extendFunctionManager = ExtendFunctionMananger(controller: self)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //初始化PagableController
        pagableController.viewController = self
        pagableController.delegate = self
        pagableController.tableView = tableView
        pagableController.isNeedRefresh = true
        pagableController.initController()
        
        //pagableController.loadMore()
        setTitle()
    }
    
    override func viewWillAppear(animated: Bool) {
        updatePlayingButton(playingButton)
    }
    
    private func setTitle() {
        switch courseType {
        case .Common:
            self.title = "往期课程"
            break
        case .Live:
            self.title = "在线直播"
            break
        case .Vip:
            self.title = "VIP课程"
            break
        }
    }
    
    //PageableControllerDelegate
    func searchHandler(respHandler: ((resp: ServerResponse) -> Void)) {
        let request = GetAlbumsRequest(courseType: courseType)
        request.pageNo = pagableController.page
        BasicService().sendRequest(ServiceConfiguration.GET_ALBUMS, request: request,
                                   completion: respHandler as ((resp: GetAlbumsResponse) -> Void))

    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "albumDetailSegue" {
            let dest = segue.destinationViewController as! AlbumDetailController
            let row = (tableView.indexPathForSelectedRow?.row)!
            dest.album = pagableController.data[row]
            dest.albumImageData = (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!)! as! AlbumCell).albumImage.image!
        } else if segue.identifier == "loadWebPageSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            let params = sender as! [String: String]
            dest.url = NSURL(string: params["url"]!)
            
            dest.title = params["title"]
        }

    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        super.audioPlayer(audioPlayer, didChangeStateFrom: from, toState: to)
        updatePlayingButton(playingButton)
    }
    
    //开始上拉到特定位置后改变列表底部的提示
    func scrollViewDidScroll(scrollView: UIScrollView){
        pagableController.scrollViewDidScroll(scrollView)
    }

}

extension AlbumListController {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pagableController.data.count

        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        
        let album = pagableController.data[indexPath.row]
        
        if album.isLive {
            let cell = tableView.dequeueReusableCellWithIdentifier("liveAlbumCell") as! LiveAlbumCell
            cell.nameLabel.text = album.name
            cell.descLabel.text = album.desc
            cell.listenPeopleLabel.text = album.listenCount
            if album.hasImage {
                //cell.albumImage.downloadedFrom(link: album.image, contentMode: UIViewContentMode.ScaleAspectFit)
                cell.albumImage.kf_setImageWithURL(NSURL(string: album.image)!)
            }
            return cell

            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("albumCell") as! AlbumCell
            cell.nameLabel.text = album.name
            cell.authorLabel.text = album.author
            
            cell.listenCountAndCountLabel.text = "\(album.listenCount), \(album.count)集"
            if album.hasImage {
                cell.albumImage.downloadedFrom(link: album.image, contentMode: UIViewContentMode.ScaleAspectFit)
            }
            return cell

        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("albumDetailSegue", sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }

}
