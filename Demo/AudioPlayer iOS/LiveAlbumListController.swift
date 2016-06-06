//
//  LiveAlbumListController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/31.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class LiveAlbumListController: AlbumListController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //不显示加载完毕的字样
        pagableController.isShowLoadCompleteText = false
        pagableController.loadMore()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if pagableController.data.count == 0 {
            return 0
        }
        
        switch section {
        case 0:
            return pagableController.data.count
        default:
            return extendFunctionManager.getRowCount()
            
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("albumCell") as! AlbumCell
            let album = pagableController.data[indexPath.row]
            cell.nameLabel.text = album.name
            cell.authorLabel.text = album.author
            cell.listenCountAndCountLabel.text = "\(album.listenCount)在线"
            if album.hasImage {
                cell.albumImage.downloadedFrom(link: album.image, contentMode: UIViewContentMode.ScaleAspectFit)
            }
            return cell
        default:
            return extendFunctionManager.getFunctionCell(tableView, row: row)
        }

        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let section = indexPath.section
        
        if section == 0 {
        
            performSegueWithIdentifier("albumDetailSegue", sender: nil)
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


}
