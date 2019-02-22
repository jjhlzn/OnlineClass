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
import SnapKit

class CodeImageViewController: BaseUIViewController, FSPagerViewDataSource, FSPagerViewDelegate {
    
    var imageUrls = [String]()
    var shareView: ShareView!
    
    /*
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    } */
    
    @IBOutlet weak var codeImageView: UIImageView!
    var qrCodeImageStore: QrCodeImageStore!
    
    //var shareManager : ShareManager!
    var pagerView: FSPagerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenWidth = UIScreen.main.bounds.width
        let width = UIScreen.main.bounds.width * 0.75
        var height = width * 1.8
        
        if height < screenWidth / 375 * 224 {
            height = screenWidth / 375 * 224
        }
        
        let frame1 = CGRect(x: 0, y: 0, width: screenWidth, height: height  )
        pagerView = FSPagerView(frame: frame1)
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "codeimage_view_cell")
        self.view.addSubview(pagerView)

        pagerView.interitemSpacing = 30
        
        
        pagerView.itemSize = CGSize(width: width, height: height)
       // pagerView.is
        pagerView.backgroundColor = UIColor.white
        pagerView.dataSource = self
        pagerView.delegate = self
        
        pagerView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(height)
            make.width.equalTo(screenWidth)
            //make.left.equalTo(10)
            make.center.equalToSuperview()
        }
        
        shareView = ShareView(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 233, width: UIScreen.main.bounds.width, height: 233), controller: self)
        shareView.shareManager.shareTitle = "识别图中二维码加入知得金融知识服务平台"
        shareView.shareManager.shareDescription = "在线学习信用卡、贷款、股票、基金、投资、理财、保险、财务等金融知识"
        setLeftBackButton()

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
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "codeimage_view_cell", at: index)
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
        pagerView.deselectItem(at: index, animated: false)
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        
        shareView.setShareUrl(imageUrls[index])
    }

    
    
}
