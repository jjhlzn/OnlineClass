//
//  LiveAlbumDetailController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/31.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer

class LiveAlbumDetailController: AlbumDetailController {
    
    var extendFunctionManager : ExtendFunctionMananger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extendFunctionManager = ExtendFunctionMananger(controller: self)
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songs == nil {
            return 0
        }
        
        switch section {
        case 0:
            return songs.count
        default:
            return extendFunctionManager.getRowCount()
        }
        
    }
    
    
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let row = indexPath.row
        let section = indexPath.section
    
        switch section {
        case 0:
            let song = songs[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("songCell") as! SongCell
            cell.nameLabel.text = song.name
            cell.descLabel.text = song.desc
            cell.dateLabel.text = song.date
            //cell.playBigImage.imageView!.image = albumImageData
            let playBigImage = cell.playBigImage
            playBigImage.kf_setImageWithURL(NSURL(string: (album?.image)!)!, forState: .Normal)
            
            playBigImage.layer.borderWidth = 0
            playBigImage.layer.masksToBounds = false
            playBigImage.layer.borderColor = UIColor.whiteColor().CGColor
            playBigImage.layer.cornerRadius = playBigImage.frame.height/2
            playBigImage.clipsToBounds = true
            
            return cell
        default:
            return extendFunctionManager.getFunctionCell(tableView, row: row)
        }
    
    
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let section = indexPath.section
        
        if section == 0 {
        
            let audioPlayer = getAudioPlayer()
            
            //检查在播放的歌曲是不是当前选中的歌曲
            let row = indexPath.row
            let song = songs[row]
            
            if audioPlayer.currentItem != nil {
                if song.wholeUrl == audioPlayer.currentItem!.highestQualityURL.URL.absoluteString {
                    performSegueWithIdentifier("songSegue", sender: false)
                    return
                }
            }
            performSegueWithIdentifier("songSegue", sender: true)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 1 {
            return 79
        } else {
            return 70
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "loadWebPageSegue" {
            let dest = segue.destinationViewController as! WebPageViewController
            let params = sender as! [String: String]
            dest.url = NSURL(string: params["url"]!)
            
            dest.title = params["title"]
        }
        
    }

}
