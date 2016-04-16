//
//  AlbumDetailController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class AlbumDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tag = "AlbumDetailController"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var albumImage: UIImageView!
    var albumImageData: UIImage!
    
    @IBOutlet weak var tableView: UITableView!
    var album: Album?
    var songs: [Song]!
    var loadingOverlay: LoadingOverlay = LoadingOverlay()
    var albumService = AlbumService()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("\(tag): viewWillAppear called")
        
        if songs == nil {
            tableView.dataSource = self
            tableView.delegate = self
            albumImage.image = albumImageData
            nameLabel.text = album?.name
            descLabel.text = ""
            loadingOverlay.showOverlay(self.view)
            albumService.getSongs(album!) { resp -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadingOverlay.hideOverlayView()
                    if resp.status != 0 {
                        print(resp.errorMessage)
                    } else {
                        self.songs = resp.songs
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songs == nil {
            return 0
        }
        return songs.count
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let song = songs[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("songCell") as! SongCell
        cell.nameLabel.text = song.name
        cell.descLabel.text = song.desc
        cell.dateLabel.text = song.date
        //cell.albumImage.downloadedFrom(link: ServiceConfiguration.GetAlbumImageUrl(self.album!.image), contentMode: .ScaleAspectFit)
        cell.albumImage.contentMode = UIViewContentMode.ScaleAspectFit
        cell.albumImage.image = albumImageData
        //cell.albumImage.image = UIImage(data: UIImagePNGRepresentation(image: albumImageData, 0.8)!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("songSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "songSegue" {
            let dest = segue.destinationViewController as! SongViewController
            dest.song = songs[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
}
