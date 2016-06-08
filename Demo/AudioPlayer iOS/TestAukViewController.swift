//
//  TestAukViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/7.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import Auk

class TestAukViewController: UIViewController {
    
    @IBOutlet weak var scrollView : UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.auk.settings.pageControl.backgroundColor =  UIColor.grayColor().colorWithAlphaComponent(0)

        // Show remote image
        scrollView.auk.show(url: "http://img.weiphone.net/1/h061/h23/bc9c8fe1img201606071030220_306__220.jpg")
        
        // Show local image
        if let image = UIImage(named: "musicCover") {
            scrollView.auk.show(image: image)
        }
        
        // Remove all images
        //scrollView.auk.removeAll()
        
        // Return the number of pages in the scroll view
        scrollView.auk.numberOfPages
        
        // Get the index of the current page or nil if there are no pages
        scrollView.auk.currentPageIndex
        
        // Return currently displayed images
        scrollView.auk.images
        
        scrollView.auk.startAutoScroll(delaySeconds: 3)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.userInteractionEnabled = true
        
        
    }
    
    func tapHandler() {
        print(scrollView.auk.currentPageIndex)
        scrollView.auk.startAutoScroll(delaySeconds: 3)

    }
}
