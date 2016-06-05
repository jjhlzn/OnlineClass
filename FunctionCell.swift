//
//  FunctionCell.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class FunctionCell: UITableViewCell {

    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var thirdLabel: UILabel!
    
    @IBOutlet weak var fourthImageView: UIImageView!
    @IBOutlet weak var fourthLabel: UILabel!
    
    func getImageView(index: Int) -> UIImageView {
        switch index {
        case 0:
            return firstImageView
        case 1:
            return secondImageView
        case 2:
            return thirdImageView
        default:
            return fourthImageView
        }
    }
    
    func getLabel(index: Int) -> UILabel {
        switch index {
        case 0:
            return firstLabel
        case 1:
            return secondLabel
        case 2:
            return thirdLabel
        default:
            return fourthLabel
        }
    }
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
                cell.getLabel(i).hidden = true
                cell.getImageView(i).hidden = true
            } else {
                let function = functions[index]
                cell.getLabel(i).text = function.name
                let imageView = cell.getImageView(i)
                imageView.image = UIImage(named: function.imageName)
                imageView.tag = index
                
                if function.isSupport {
                    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageHandler)))
                    cell.getLabel(i).addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageHandler)))
                } else {
                    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unSupportHandler)))
                    cell.getLabel(i).addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unSupportHandler)))
                }
                
                imageView.userInteractionEnabled = true
                cell.getLabel(i).userInteractionEnabled = true
                index = index + 1
            }
        }
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
        return cell
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
