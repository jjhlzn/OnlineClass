//
//  FunctionCell.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class FunctionCell: UITableViewCell {


    
    var images = [UIImageView]()
    var labels = [UILabel]()
    
 
}

 class ExtendFunctionMananger : NSObject {
    
    var controller : BaseUIViewController
    
    var functions = [
                     ExtendFunction(imageName: "commonCard", name: "去刷卡", isSupport: true, url: "http://www.baidu.com"),
                     ExtendFunction(imageName: "up", name: "一键提额", isSupport: true, url: "http://www.baidu.com"),
                     ExtendFunction(imageName: "visa", name: "一键办卡", isSupport: true, url: "http://www.weibo.com"),
                     ExtendFunction(imageName: "cardManage", name: "卡片管理", isSupport: false, url: "http://www.weibo.com"),
                     ExtendFunction(imageName: "creditSearch", name: "信用查询", isSupport: true, url: "http://www.weibo.com"),
                     ExtendFunction(imageName: "mmcSearch", name: "mcc查询", isSupport: true, url: "http://www.weibo.com"),
                     ExtendFunction(imageName: "shopcart", name: "商城", isSupport: false, url: "http://www.weibo.com"),
                     ExtendFunction(imageName: "rmb", name: "缴费", isSupport: false, url: "http://www.weibo.com"),
                     ExtendFunction(imageName: "dollar", name: "贷款", isSupport: false, url: "http://www.weibo.com"),
                    ]
    
    init(controller: BaseUIViewController) {
        self.controller = controller
    }
    
    
    func getRowCount() -> Int {
        return (functions.count + 3) / 4
    }
    
    func getFunctionCell(tableView: UITableView, row: Int) -> FunctionCell {
        var index = row * 4
        let cell = tableView.dequeueReusableCellWithIdentifier("functionCell") as! FunctionCell
        
        for i in 0...3 {
            if index >= functions.count {
                break
            }
            print("row = \(row), index = \(index)")
            let function = functions[index]
            let imageView = makeImage(row, column: i, index: index, function: function)
            cell.addSubview(imageView)
            
            let label = makeLabel(row, column: i, index: index, function: function, imageView: imageView)
            cell.addSubview(label)
            
            cell.images.append(imageView)
            cell.labels.append(label)
            index = index + 1
            
        }
        
        cell.separatorInset = UIEdgeInsetsMake(0, UIScreen.mainScreen().bounds.width, 0, 0);
        print(cell)
        return cell
    }
    
    
    let imageWidth : CGFloat = 40
    let cellHeight = 79
    private func makeImage(row : Int, column : Int, index: Int, function: ExtendFunction) -> UIImageView {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let firstPart = CGFloat(screenWidth) - CGFloat(20) * CGFloat(2) - CGFloat(imageWidth) * 4
        let interval = firstPart / 3
        let x = 20 + (CGFloat(imageWidth) + interval) * CGFloat(column)
        let y = 10
        let imageView = UIImageView(frame: CGRectMake(x, CGFloat(y), imageWidth, imageWidth))
        imageView.image = UIImage(named: function.imageName)
        imageView.tag = index
        if function.isSupport {
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageHandler)))
        } else {
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unSupportHandler)))
        }
        
        imageView.userInteractionEnabled = true
        return imageView
    }
    
    private func makeLabel(row : Int, column : Int, index: Int, function: ExtendFunction, imageView: UIImageView) -> UILabel {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let labelWidth =  screenWidth / 4
        let x =  labelWidth * CGFloat(column)
        let y = 54
        let label = UILabel(frame: CGRectMake(x, CGFloat(y), labelWidth, 21))
        label.textAlignment = .Center
        label.font = label.font.fontWithSize(13)
        label.center.x = imageView.center.x
        label.text = function.name
        if function.isSupport {
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageHandler)))
        } else {
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unSupportHandler)))
        }
        label.userInteractionEnabled = true
        return label
        
    }
    
    
    
    func imageHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        let function = functions[index!]
        let params : [String: String] = ["url": function.url, "title": function.name]
        controller.performSegueWithIdentifier("loadWebPageSegue", sender: params)
    }
    
    func unSupportHandler(sender: UITapGestureRecognizer? = nil) {
        controller.displayMessage("敬请期待")
    }
    

}

class ExtendFunction {
    var imageName = ""
    var name = ""
    var url = ""
    var isSupport = false
    var actiono : UITapGestureRecognizer?
    
    init(imageName: String, name: String, isSupport: Bool, url: String) {
        self.imageName = imageName
        self.name = name
        self.isSupport = isSupport
        self.url = url
    }
}
