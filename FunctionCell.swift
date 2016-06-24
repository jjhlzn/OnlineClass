//
//  FunctionCell.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class FunctionCell: UITableViewCell {


    
    //var images = [UIImageView]()
    //var labels = [UILabel]()
    
 
}

class ExtendFunctionMananger : NSObject {
    
    var controller : BaseUIViewController
    var showMaxRows : Int
    var moreFunction : ExtendFunction?
    var isNeedMore = false
    
    var functions : [ExtendFunction] = [ExtendFunction]()
    
    init(controller: BaseUIViewController, isNeedMore: Bool = true, showMaxRows : Int = 100) {
        self.controller = controller
        self.showMaxRows = showMaxRows
        self.isNeedMore = isNeedMore
        
        super.init()
        moreFunction = ExtendFunction(imageName: "moreFunction", name: "更多",  url: "",
                                      selector: #selector(moreHanlder))
        
        functions = [
            ExtendFunction(imageName: "commonCard", name: "去刷卡", url: "http://www.baidu.com",
                selector:  #selector(imageHandler)),
            ExtendFunction(imageName: "up", name: "一键提额", url: "http://114.215.236.171:6012/Service/CreditLines",
                selector:  #selector(imageHandler)),
            ExtendFunction(imageName: "visa", name: "一键办卡", url: "http://114.215.236.171:6012/Service/FastCard",
                selector:  #selector(imageHandler)),
            ExtendFunction(imageName: "cardManage", name: "卡片管理", url: "http://114.215.236.171:6012/Service/CardManage",
                selector:  #selector(unSupportHandler)),
            ExtendFunction(imageName: "creditSearch", name: "信用查询", url: "http://114.215.236.171:6012/Service/Ipcrs",
                selector:  #selector(imageHandler)),
            ExtendFunction(imageName: "mmcSearch", name: "mcc查询",  url: "http://114.215.236.171:6012/Service/MccSearch",
                selector:  #selector(imageHandler)),
            ExtendFunction(imageName: "shopcart", name: "商城",  url: "http://www.weibo.com",
                selector:  #selector(unSupportHandler)),
            ExtendFunction(imageName: "rmb", name: "缴费",  url: "http://www.weibo.com",
                 selector:  #selector(unSupportHandler)),
            ExtendFunction(imageName: "dollar", name: "贷款", url: "http://www.weibo.com",
                 selector:  #selector(unSupportHandler)),
            ExtendFunction(imageName: "car", name: "汽车分期", url: "http://www.weibo.com",
                selector:  #selector(unSupportHandler)),
            ExtendFunction(imageName: "customerservice", name: "客服", url: "http://www.weibo.com",
                selector:  #selector(unSupportHandler)),
            moreFunction!
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
        /*
        let buttonCount = showMaxRows * buttonCountEachRow
        if buttonCount < functions.count {
            return true
        } else {
            return false
        } */
        return isNeedMore
    }
    
    func getFunctionCell(tableView: UITableView, row: Int) -> FunctionCell {
        var index = row * buttonCountEachRow
        let cell = tableView.dequeueReusableCellWithIdentifier("functionCell") as! FunctionCell
        //print("row = \(row)")
        for i in 0...(buttonCountEachRow - 1) {
            
            if index >= functions.count {
                //print("index = \(index), functions.count = \(functions.count)")
                break
            }
            
            // print("index = \(index)")
            
            let function = functions[index]
            if !isNeedMoreButton() && function.name == moreFunction!.name {
                break
            }
            
            //print("cell.width = \(cell.bounds.width)")
            addCellView(row, column: i, index: index, function: function, cell: cell)
            
           
            index = index + 1
            
        }
        
        cell.separatorInset = UIEdgeInsetsMake(0, UIScreen.mainScreen().bounds.width, 0, 0);
        return cell
    }
    
    
    private func addCellView(row : Int, column : Int, index: Int, function: ExtendFunction, cell: UITableViewCell) -> UIView {
        let interval : CGFloat = UIScreen.mainScreen().bounds.width / 4
        let x = interval  * CGFloat(column)
        let cellView = UIView(frame: CGRectMake(x, 0, interval, 79))
        cellView.tag = index
        
        cell.addSubview(cellView)
        
        let imageView = makeImage(index, function: function, superView: cellView)
        let label =     makeLabel(index, function: function, superView: cellView)
        
        cellView.addSubview(imageView)
        cellView.addSubview(label)
        
        if function.action != nil {
            cellView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: function.action ))
            cellView.userInteractionEnabled = true
        }
        
        return cellView

    }
    
    
    let imageWidth : CGFloat = 40
    let cellHeight = 79
    private func makeImage(index: Int, function: ExtendFunction, superView: UIView) -> UIImageView {
        let imageView = UIImageView(frame: CGRectMake(0, 0, imageWidth, imageWidth))
        imageView.center.x = superView.bounds.width / 2
        imageView.center.y = superView.bounds.height / 2 - 10
        //print("superView.center.x = \(superView.center.x), superView.center.y - 10 = \(superView.center.y - 10)")
        imageView.image = UIImage(named: function.imageName)
        imageView.tag = index
        
        return imageView
    }
    
    private func makeLabel(index: Int, function: ExtendFunction, superView: UIView) -> UILabel {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let labelWidth =  screenWidth / 4
        
        let label = UILabel(frame: CGRectMake(0, 0, labelWidth, 21))
        label.tag = index
        
        label.center.x = superView.bounds.width / 2
        label.center.y = superView.bounds.height / 2 + imageWidth / 2 + 5

        label.textAlignment = .Center
        label.font = label.font.fontWithSize(13)
        label.textColor = UIColor.blackColor()
        label.text = function.name
        
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
