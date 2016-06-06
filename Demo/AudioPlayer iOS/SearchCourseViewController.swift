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

    @IBOutlet weak var searchTipView: UIView!
    
    @IBOutlet weak var searchView: UIView!
    var searchTipViewBackup :UIView?
    
    var loading = LoadingOverlay()
    
    var request : SearchRequest?
    
    var hotSearchKeywords = ["信用卡", "提高额度", "办卡"]
    
    var pagableController = PagableController<Album>()
    
    override func viewDidLoad() {

        //故意不掉用父类的viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

    
        searchField.delegate = self
        //searchField.becomeFirstResponder()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchField.clearButtonMode = UITextFieldViewMode.Always
        addIconToField(searchField, imageName: "search-filled")
        
        //初始化PagableController
        pagableController.viewController = self
        pagableController.delegate = self
        pagableController.tableView = tableView
        pagableController.hasMore = false
        pagableController.isNeedRefresh = false
        pagableController.initController()
    
        drawHotKeywordButtons()
        self.searchTipView.removeFromSuperview()
        view.addSubview(searchTipView)
       
        
        
        
    }
    
    private func drawHotKeywordButtons() {
        var index = 0
        for item in hotSearchKeywords {
            searchTipView.addSubview(drawHotkeywordButton(item, index: index))
            index = index + 1
        }

    }
    
    private func drawHotkeywordButton(keyword: String, index: Int) -> UIButton {
        let screenSize = UIScreen.mainScreen().bounds
        
        let x = 0
        let y = 84 + index * 36
        
        let button = UIButton(frame: CGRect(x: x, y: y, width: Int(screenSize.width), height: 21))
        print("x = \(x), y = \(y), width = \(screenSize.width), height = 21, keyword = \(keyword)")
        button.setTitle(keyword, forState: .Normal)
        button.setTitleColor(UIColor(colorLiteralRed: 1, green: 0x6e/0xff, blue: 0x36/0xff, alpha: 1), forState: .Normal)
        button.addTarget(self, action: #selector(tapKeyword), forControlEvents: .TouchUpInside)
            //
        return button
    }
    
    func tapKeyword(sender: UIButton!) {
        let title = sender.titleLabel?.text
        searchField.text = title
        executeSearch()
    }
    
    func addIconToField(field: UITextField, imageName: String) {
        let imageView = UIImageView();
        let image = UIImage(named: imageName);
        imageView.frame = CGRect(x: 5, y: 4, width: 15, height: 15)
        view.addSubview(imageView)
        imageView.image = image;
        //field.leftView = imageView
        
        //field.leftViewMode = UITextFieldViewMode.Always
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 20, 25))
        paddingView.addSubview(imageView)
        field.leftView = paddingView;
        field.leftViewMode = UITextFieldViewMode.Always
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController != nil {
            self.navigationController?.navigationBarHidden = true
            
        }
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        cancleHideKeybaordWhenTappedAround()
        self.navigationController?.navigationBarHidden = false
    }



    
    func searchHandler(respHandler: ((resp: ServerResponse) -> Void)) {
    
        if request == nil {
            return
        }
    
        BasicService().sendRequest(ServiceConfiguration.SEARCH,
                                   request: request!, completion: respHandler as ((resp: SearchResponse) -> Void))
        

    }

    
    
    
    //开始上拉到特定位置后改变列表底部的提示
    func scrollViewDidScroll(scrollView: UIScrollView){
        pagableController.scrollViewDidScroll(scrollView)
    }

    
    var overlay : UIView!
    private func addGraylayer() {
        
        var frame = UIScreen.mainScreen().bounds
        frame.origin.y = 65

        overlay = UIView(frame: frame)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.3)
        view.addSubview(overlay)
    }
    
    private func removeGraylayer() {
        overlay.removeFromSuperview()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hideKeyboardWhenTappedAround()
        addGraylayer()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        cancleHideKeybaordWhenTappedAround()
        removeGraylayer()
        
        if searchField.text?.length == 0 {
            if searchTipView != nil {
                searchTipView.removeFromSuperview()
            }
            if (searchTipViewBackup != nil) {
                view.addSubview(searchTipViewBackup!)
                searchTipView = searchTipViewBackup
            }
        }
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        executeSearch()
        
        return false
    }
    
    func executeSearch() {
        pagableController.hasMore = true
        let keyword = searchField.text
        
        request = SearchRequest()
        request?.keyword = keyword!
        
        //reset tableView
        pagableController.reset()
        
        self.searchTipViewBackup = self.searchTipView
        if self.searchTipView != nil {
            self.searchTipView.removeFromSuperview()
        }
        
        loading.showOverlay(view)
        searchHandler() {
            (resp: ServerResponse) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.loading.hideOverlayView()
                self.pagableController.afterHandleResponse(resp as! GetAlbumsResponse)
            }
        }

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