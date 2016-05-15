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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        addPlayingButton(playingButton)
        tableView.dataSource = self
        tableView.delegate = self
        
        //初始化PagableController
        pagableController.viewController = self
        pagableController.delegate = self
        pagableController.tableView = tableView
        
        //pagableController.loadMore()
        setTitle()
    }
    
    override func viewWillAppear(animated: Bool) {
        updatePlayingButton(playingButton)
    }
    
    private func setTitle() {
        switch courseType {
        case .Common:
            
            break
        case .Live:
            self.title = "直播课程"
            break
        case .Vip:
            self.title = "VIP课程"
            break
            
        default:
            break
        }
    }
    
    //PageableControllerDelegate
    func searchHandler() {
        var params = [String: AnyObject]()
        switch courseType {
        case .Common:
            params = ["type": "common"]
            break
        case .Live:
            params = ["type": "live"]
            break
        case .Vip:
            params = ["type": "vip"]
            break
            
        default:
            break
        }
        BasicService().sendRequest(ServiceConfiguration.GET_ALBUMS, params: params) {
            (resp: GetAlbumsResponse) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.pagableController.afterHandleResponse(resp)
            }
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "albumDetailSegue" {
            let dest = segue.destinationViewController as! AlbumDetailController
            let row = (tableView.indexPathForSelectedRow?.row)!
            dest.album = pagableController.data[row]
            dest.albumImageData = (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!)! as! AlbumCell).albumImage.image!
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
        let cell = tableView.dequeueReusableCellWithIdentifier("albumCell") as! AlbumCell
        let album = pagableController.data[indexPath.row]
        cell.nameLabel.text = album.name
        cell.authorLabel.text = album.author
        if album.hasImage {
            cell.albumImage.downloadedFrom(link: "\(ServiceConfiguration.ImageUrlPrefix)/\(album.image)", contentMode: UIViewContentMode.ScaleAspectFit)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.selectionStyle = .None
        performSegueWithIdentifier("albumDetailSegue", sender: nil)
        
    }

}
