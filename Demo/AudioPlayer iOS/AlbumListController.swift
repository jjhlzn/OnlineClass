//
//  AlbumListController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class AlbumListController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var playingButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    var albums: [Album] = []
    
    override func viewWillAppear(animated: Bool) {
        addPlayingButton(playingButton)
        tableView.dataSource = self
        tableView.delegate = self
        
        AlbumService().getAlbums() { response -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if response.status != 0 {
                    print(response.errorMessage)
                } else {
                    self.albums = response.albums
                    print("albums.count = \(self.albums.count)")
                    self.tableView.reloadData()
                    
                }
            }
            
        }
        updatePlayingButton(playingButton)
        
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumCell") as! AlbumCell
        let album = albums[indexPath.row]
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "albumDetailSegue" {
            let dest = segue.destinationViewController as! AlbumDetailController
            let row = (tableView.indexPathForSelectedRow?.row)!
            dest.album = albums[row]
            dest.albumImageData = (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!)! as! AlbumCell).albumImage.image!
        }
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        super.audioPlayer(audioPlayer, didChangeStateFrom: from, toState: to)
        updatePlayingButton(playingButton)
    }

}
