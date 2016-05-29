//
//  SearchCourseViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/29.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class SearchCourseViewController: BaseUIViewController, UITextFieldDelegate , PagableControllerDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var searchField: UITextField!
    
    var loading = LoadingOverlay()
    
    var request : SearchRequest?
    
    var pagableController = PagableController<Album>()
    
    override func viewDidLoad() {

        //故意不掉用父类的viewDidLoad()
    
        searchField.delegate = self
        searchField.becomeFirstResponder()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //初始化PagableController
        pagableController.viewController = self
        pagableController.delegate = self
        pagableController.tableView = tableView
        pagableController.hasMore = false
        
        addTopLayer()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController != nil {
            self.navigationController?.navigationBarHidden = true
            
        }
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    var topView: UIView!
    private func addTopLayer() {
        topView = UIView(frame: tableView.frame)
        view.addSubview(topView)
    }
    
    private func removeTopLayer() {
        topView.removeFromSuperview()
    }
    
    //PageableControllerDelegate
    func searchHandler() {
        if request == nil {
            return
        }
        
        BasicService().sendRequest(ServiceConfiguration.SEARCH, request: request!) {
            (resp: SearchResponse) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.removeTopLayer()
                self.pagableController.afterHandleResponse(resp)
            }
        }
        
    }
    //开始上拉到特定位置后改变列表底部的提示
    func scrollViewDidScroll(scrollView: UIScrollView){
        pagableController.scrollViewDidScroll(scrollView)
    }



    @IBAction func cancelPressed(sender: AnyObject) {
       self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.navigationController != nil {
            
            self.navigationController?.navigationBarHidden = false
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        pagableController.hasMore = true
        let keyword = searchField.text
        
        request = SearchRequest()
        request?.keyword = keyword!
        
        //reset tableView
        pagableController.reset()

        searchHandler()
        return false
    }
}


extension  SearchCourseViewController :  UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pagableController.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumCell") as! AlbumCell
        let album = pagableController.data[indexPath.row]
        cell.nameLabel.text = album.name
        cell.authorLabel.text = album.author
        if album.hasImage {
            cell.albumImage.downloadedFrom(link: album.image, contentMode: UIViewContentMode.ScaleAspectFit)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("albumDetailSegue", sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "albumDetailSegue" {
            let dest = segue.destinationViewController as! AlbumDetailController
            let row = (tableView.indexPathForSelectedRow?.row)!
            dest.album = pagableController.data[row]
            dest.albumImageData = (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!)! as! AlbumCell).albumImage.image!
        }
    }
}