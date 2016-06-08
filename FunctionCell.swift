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
    var showMaxRows : Int
    var moreFunction : ExtendFunction?
    
    var functions : [ExtendFunction] = [ExtendFunction]()
    
    init(controller: BaseUIViewController, showMaxRows : Int = 100) {
        self.controller = controller
        self.showMaxRows = showMaxRows
        
        
        super.init()
        moreFunction = ExtendFunction(imageName: "moreFunction", name: "更多",  url: "",
                                      selector: #selector(moreHanlder))
        functions = [
            ExtendFunction(imageName: "commonCard", name: "去刷卡", url: "http://www.baidu.com",
                selector:  #selector(imageHandler)),
            ExtendFunction(imageName: "up", name: "一键提额", url: "http://www.baidu.com",
                selector:  #selector(imageHandler)),
            ExtendFunction(imageName: "visa", name: "一键办卡", url: "http://www.weibo.com",
                selector:  #selector(imageHandler)),
            ExtendFunction(imageName: "cardManage", name: "卡片管理", url: "http://www.weibo.com",
                selector:  #selector(unSupportHandler)),
            ExtendFunction(imageName: "creditSearch", name: "信用查询", url: "http://www.weibo.com",
                selector:  #selector(imageHandler)),
            ExtendFunction(imageName: "mmcSearch", name: "mcc查询",  url: "http://www.weibo.com",
                selector:  #selector(imageHandler)),
            ExtendFunction(imageName: "shopcart", name: "商城",  url: "http://www.weibo.com",
                selector:  #selector(unSupportHandler)),
            ExtendFunction(imageName: "rmb", name: "缴费",  url: "http://www.weibo.com",
                 selector:  #selector(unSupportHandler)),
            ExtendFunction(imageName: "dollar", name: "贷款", url: "http://www.weibo.com",
                 selector:  #selector(unSupportHandler)),
        ]
        
    }
    
    let buttonCountEachRow = 4
    func getRowCount() -> Int {
        let rows = (functions.count + buttonCountEachRow - 1) / buttonCountEachRow
        let result = rows > showMaxRows ? showMaxRows : rows
        //print("result = \(result)")
        return result
    }
    
    func isNeedMoreButton() -> Bool {
        let buttonCount = showMaxRows * buttonCountEachRow
        if buttonCount < functions.count {
            return true
        } else {
            return false
        }
    }
    
    func getFunctionCell(tableView: UITableView, row: Int) -> FunctionCell {
        var index = row * buttonCountEachRow
        let cell = tableView.dequeueReusableCellWithIdentifier("functionCell") as! FunctionCell
        //print("row = \(row)")
        for i in 0...(buttonCountEachRow - 1) {
            
            if index >= functions.count {
                print("index = \(index), functions.count = \(functions.count)")
                break
            }
            
            // print("index = \(index)")
            
            var function = functions[index]
            if isNeedMoreButton()  && index == (showMaxRows * buttonCountEachRow - 1) {
                function = moreFunction!
            }
            
            
            let imageView = makeImage(row, column: i, index: index, function: function)
            cell.addSubview(imageView)
            
            let label = makeLabel(row, column: i, index: index, function: function, imageView: imageView)
            cell.addSubview(label)
            
            cell.images.append(imageView)
            cell.labels.append(label)
            index = index + 1
            
        }
        
        cell.separatorInset = UIEdgeInsetsMake(0, UIScreen.mainScreen().bounds.width, 0, 0);
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
        if function.action != nil {
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: function.action ))
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
        if function.action != nil {
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: function.action ))
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
    
    func moreHanlder(sender: UITapGestureRecognizer? = nil) {
        controller.performSegueWithIdentifier("moreFunctionSegue", sender: nil)
    }
    
    
}

class ExtendFunction {
    var imageName = ""
    var name = ""
    var url = ""
    var isSupport = false
    var action : Selector
    
    init(imageName: String, name: String, url: String, selector: Selector) {
        self.imageName = imageName
        self.name = name
        self.url = url
        self.action = selector
    }
}
