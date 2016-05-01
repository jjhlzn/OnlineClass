//
//  AlbumListController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class AlbumListController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate, PagableControllerDelegate {
    
    @IBOutlet weak var playingButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    var pagableController = PagableController<Album>()
    
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
    
    }
    
    override func viewWillAppear(animated: Bool) {
        updatePlayingButton(playingButton)
    }
    
    //PageableControllerDelegate
    func searchHandler() {
        BasicService().sendRequest(ServiceConfiguration.GET_ALBUMS) {
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
        performSegueWithIdentifier("albumDetailSegue", sender: nil)
    }

}
