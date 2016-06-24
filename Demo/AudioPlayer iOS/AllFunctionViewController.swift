//
//  AllFunctionViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/8.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class AllFunctionViewController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var extendFunctionMananger : ExtendFunctionMananger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extendFunctionMananger = ExtendFunctionMananger(controller: self, isNeedMore: false)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extendFunctionMananger.getRowCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return extendFunctionMananger.getFunctionCell(tableView, row: indexPath.row)
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
