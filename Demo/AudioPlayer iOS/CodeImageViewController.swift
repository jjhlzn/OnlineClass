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
    
 
    var imageUrls = [String]()
    var shareView: ShareView!
    
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
        
        shareView = ShareView(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 233, width: UIScreen.main.bounds.width, height: 233), controller: self)
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

    
    @IBAction func shareBtnPressed(_ sender: Any) {
        shareView.show()
    }
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return imageUrls.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.contentView.layer.shadowRadius = 0
        cell.textLabel?.backgroundColor = nil
        cell.imageView?.kf.setImage(with: URL(string: imageUrls[index]))
        QL1(imageUrls[index])
        //cell.imageView?.image = UIImage(named: "icon")
        cell.imageView?.contentMode = .scaleToFill
        cell.textLabel?.text = String("")
        return cell
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        //QL1("FSPagerView index = " + String(index) + " selected")
        pagerView.deselectItem(at: index, animated: true)
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        
        shareView.setShareUrl(imageUrls[index])
    }

    
    
}
