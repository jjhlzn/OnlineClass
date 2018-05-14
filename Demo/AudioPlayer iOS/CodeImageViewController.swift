//
//  CodeImageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/8.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import Kingfisher
import QorumLogs
import FSPagerView
import Kingfisher

class CodeImageViewController: BaseUIViewController, FSPagerViewDataSource, FSPagerViewDelegate {
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var pengyouquanButton: UIButton!
    @IBOutlet weak var wechatButton: UIButton!
    var imageUrls = [String]()
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    
    @IBOutlet weak var codeImageView: UIImageView!
    var qrCodeImageStore: QrCodeImageStore!
    
    var shareManager : ShareManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pagerView.interitemSpacing = 30
        let width = UIScreen.main.bounds.width * 0.75
        let height = width * 1.8
        pagerView.itemSize = CGSize(width: width, height: height)
       // pagerView.is
        pagerView.backgroundColor = UIColor.white
        pagerView.dataSource = self
        pagerView.delegate = self
        
        /*
        let loginUser = LoginUserStore().getLoginUser()!
        
        qrCodeImageStore = QrCodeImageStore()
    
        shareManager = ShareManager(controller: self)
        shareManager.shareDescription = "扫一扫下载安装【巨方助手】，即可免费在线学习、提额、办卡、贷款！"
        
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            print("winxin share is OK")
        } else {
            print("winxin share is  NOT OK")
        }*/
        loadData()
    }
    
    private func loadData() {
        let request = GetShareImagesRequest()
        BasicService().sendRequest(url: ServiceConfiguration.GET_SHARE_IMAGES, request: request) {
            (resp : GetShareImagesResponse) -> Void in
            //self.loading.hideOverlayView()
            self.imageUrls = resp.shareImages
            self.pagerView.reloadData()
        }
    }
    
    func addLineBorder(field: UIButton) {
        /*
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, 0, field.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        field.layer.addSublayer(bottomBorder)
 */
    }
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return imageUrls.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.contentView.layer.shadowRadius = 0
        cell.imageView?.kf.setImage(with: URL(string: imageUrls[index]))
        QL1(imageUrls[index])
        //cell.imageView?.image = UIImage(named: "icon")
        cell.imageView?.contentMode = .scaleToFill
        cell.textLabel?.text = String("")
        return cell
    }

    
    @IBAction func shareToFriends(sender: AnyObject) {
        shareManager.shareToWeixinFriend()
    }

    @IBAction func shareToPengyouquan(sender: AnyObject) {
        shareManager.shareToWeixinPengyouquan()
    }
    
    @IBAction func shareToWeibo(sender: AnyObject) {
        shareManager.shareToWeibo()
    }
    
    @IBAction func shareToQQFriends(sender: AnyObject) {
        shareManager.shareToQQFriend()
    }
    
    
    @IBAction func shareToQzone(sender: AnyObject) {
        shareManager.shareToQzone()
    }
    
    @IBAction func copyLink(sender: AnyObject) {
        shareManager.copyLink()
    }
    
    
    
}
