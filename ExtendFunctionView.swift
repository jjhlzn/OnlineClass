//
//  ExtendFunctionView.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/10/20.
//  Copyright © 2018 tbaranes. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import QorumLogs

class ExtendFunctionView: UIView {

    var imageView: UIImageView!
    var label: UILabel!
    

    
    init(frame: CGRect, index: Int, function: ExtendFunction, superView: UIView) {
        super.init(frame: frame)

        imageView = makeImage(index: index, function: function, superView: superView)
        label =     makeLabel(index: index, function: function, superView: superView)
        
        self.addSubview(imageView)
        self.addSubview(label)
        
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        imageView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
            make.width.equalTo(getImageWidth())
            make.height.equalTo(getImageWidth())
        }
        
        label.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(5)
        }
        
        super.updateConstraints()
    }

    var buttonCountEachRow = 5
    private func getImageWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        if UIDevice().isIphone4Like() {
            return screenWidth / CGFloat(buttonCountEachRow) * 0.65 * 0.55
        } else {
            return screenWidth / CGFloat(buttonCountEachRow) * 0.7 * 0.49
        }
    }
    
    private func makeImage(index: Int, function: ExtendFunction, superView: UIView) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: getImageWidth(), height: getImageWidth()))

    
        
        overlayImage(function: function, imageView: imageView) //UIImage(named: function.imageName)
        imageView.tag = index
        
        return imageView
    }
    
    func overlayImage(function: ExtendFunction, imageView: UIImageView)  {
        let viwe = UIImageView()
        
        if function.imageName != "" {
            let url = ImageResource(downloadURL: URL(string: function.imageName)!, cacheKey: function.imageUrl)
            
            ImageCache.default.retrieveImage(forKey: function.imageUrl, options: nil) {
                image, cacheType in
                if let image = image {
                    print("Get image \(image), cacheType: \(cacheType).")
                    //In this code snippet, the `cacheType` is .disk
                    imageView.image = self.overlayImage0(function: function, bottomImg: image)
                } else {
                    //QL1(function.imageName)
                    viwe.kf.setImage(with: url, completionHandler: {
                        (image, error, cacheType, imageUrl) in
                        if image != nil {
                            imageView.image = self.overlayImage0(function: function, bottomImg: image!)
                            QL1("update icon for: \(function.name)")
                        }
                    })
                    
                    imageView.image = self.overlayImage0(function: function, bottomImg: UIImage(named: "func_placeholder")!)
                }
            }
        } else {
            imageView.image = self.overlayImage0(function: function, bottomImg: UIImage(named: "func_placeholder")!)
        }
        
        
    }
    
    func overlayImage0(function: ExtendFunction, bottomImg: UIImage) -> UIImage {
        var bottomImage = bottomImg
        let extendFunctionImageStore = ExtendFunctionImageStore()
        // QL1("\(function.code):  \(function.name), \(function.imageUrl)")
        if function.imageUrl != "" {
            let image = extendFunctionImageStore.getImage(imageUrl: function.imageUrl)
            if image != nil {
                bottomImage = image!
            }
        }
        
        if !function.hasMessage {
            return bottomImage
        }
        
        let topImage = UIImage(named: "message_one")!
        
        let newSize = CGSize(width: getImageWidth(), height: getImageWidth()) // set this to what you need
        let ratio : CGFloat = 0.42
        let messageSize = CGSize(width: getImageWidth() * ratio, height: getImageWidth() * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        let x = getImageWidth() - abs(getImageWidth() - getImageWidth() * ratio) * 1.3 / 2
        let y = getImageWidth() * ratio / 5 - 2
        
        bottomImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        topImage.draw(in: CGRect(origin: CGPoint(x: x, y: CGFloat(y)), size: messageSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    private func makeLabel(index: Int, function: ExtendFunction, superView: UIView) -> UILabel {
        let screenWidth = UIScreen.main.bounds.width
        let labelWidth =  screenWidth / CGFloat(buttonCountEachRow)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 20))
        label.tag = index
        
        var fontSize : CGFloat = 13
        if UIDevice().isIphonePlusLike() {
        } else if UIDevice().isIphone6Like() {
        } else {
            fontSize = 12
        }
        
        label.textAlignment = .center
        label.font = label.font.withSize(fontSize)
        label.textColor = UIColor.darkGray
        label.text = function.name
        
        return label
    }
}
