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
        extendFunctionManager = ExtendFunctionMananger.instance
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let row = indexPath.row
        let section = indexPath.section
    
        switch section {
        case 0:
            let song = songs[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell") as! SongCell
            cell.nameLabel.text = song.name
            cell.descLabel.text = song.desc
            cell.dateLabel.text = song.date
            //cell.playBigImage.imageView!.image = albumImageData
            let playBigImage = cell.playBigImage
            //TODO:
            //playBigImage.kf_setImageWithURL(NSURL(string: (album?.image)!)!, forState: .Normal)
            
            playBigImage?.layer.borderWidth = 0
            playBigImage?.layer.masksToBounds = false
            playBigImage?.layer.borderColor = UIColor.white as! CGColor
            playBigImage?.layer.cornerRadius = (playBigImage?.frame.height)!/2
            playBigImage?.clipsToBounds = true
            
            return cell
        default:
            return extendFunctionManager.getFunctionCell(tableView: tableView, row: row)
        }
    
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let section = indexPath.section
        
        if section == 0 {
        
            let audioPlayer = getAudioPlayer()
            
            //检查在播放的歌曲是不是当前选中的歌曲
            let row = indexPath.row
            let song = songs[row]
            
            if audioPlayer.currentItem != nil {
                //TODO:
                /*
                if song.wholeUrl == audioPlayer.currentItem!.highestQualityURL.URL.absoluteString {
                    performSegue(withIdentifier: "songSegue", sender: false)
                    return
                } */
            }
            performSegue(withIdentifier: "songSegue", sender: true)
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        } else {
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "loadWebPageSegue" {
            let dest = segue.destination as! WebPageViewController
            let params = sender as! [String: String]
            dest.url = NSURL(string: params["url"]!)
            
            dest.title = params["title"]
        }
        
    }

}
