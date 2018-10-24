//
//  FunctionCell.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs
import Kingfisher

class FunctionCell: UITableViewCell {
 
}

class ExtendFunctionMananger : NSObject {
    
    
    var controller : BaseUIViewController!
    var showMaxRows : Int
    static var moreFunction : ExtendFunction?
    var isNeedMore = true
    var extendFunctionStore = ExtendFunctionStore.instance
    
    private var _functions : [ExtendFunction] = [ExtendFunction]()
    
    static var instance = ExtendFunctionMananger()
    
    var functions: [ExtendFunction] {
        get {
            //return ExtendFunctionMananger.allFunctions
            return _functions
        }
        set {
            _functions = newValue
        }
    }
    
    func makeFunction(imageName: String, name: String, code: String, url: String, messageCount: Int, selectorName: String) -> ExtendFunction {
        QL1(selectorName)
        var selector = #selector(imageHandler)
        if selectorName == "dingyueHandler" {
            selector = #selector(dingyueHandler)
        } else if selectorName == "moreHanlder" {
            selector = #selector(moreHanlder)
        } else if selectorName == "jpkHandler" {
            selector = #selector(jpkHandler(sender:))
        } else if selectorName == "questionHandler" {
            selector = #selector(questionHandler(sender:))
        }
        return ExtendFunction(imageName: imageName, name: name, code: code, url: url, messageCount: messageCount,
                       selector:  selector, isShowDefault: true)
    }
    
    static func getAllFunctions() -> [ExtendFunction] {
        return [];
        
    }
    
    private init(controller: BaseUIViewController, isNeedMore: Bool = true, showMaxRows : Int = 100) {
        self.controller = controller
        self.showMaxRows = showMaxRows
        self.isNeedMore = isNeedMore
        
        super.init()
    }
    
    func setConfig(controller: BaseUIViewController, isNeedMore: Bool = true, showMaxRows : Int = 100) {
        self.controller = controller
        self.showMaxRows = showMaxRows
        self.isNeedMore = isNeedMore
    }
    
    
    private func getFunction(code: String) -> ExtendFunction? {
        for function in functions {
            if function.code == code {
                return function
            }
        }
        return nil
    }
    
    init(isNeedMore: Bool = true, showMaxRows : Int = 100) {
        self.showMaxRows = showMaxRows
        self.isNeedMore = isNeedMore
        
        super.init()
    }

    
    let buttonCountEachRow = 5
    func getRowCount() -> Int {
        let rows = (functions.count + buttonCountEachRow - 1) / buttonCountEachRow
        //QL1("rows = \(rows)")
        let result = rows > showMaxRows ? showMaxRows : rows
        //print("result = \(result)")
        return result
    }
    
    func isNeedMoreButton() -> Bool {
        return isNeedMore
    }
    
    private func getLastIndex() -> Int {
        let buttonCount = showMaxRows * buttonCountEachRow
        return buttonCount < functions.count ? buttonCount - 1 : functions.count - 1
    }
    
    func getFunctionCell(tableView: UITableView, row: Int, isNeedMore: Bool = true) -> FunctionCell {
        var index = row * buttonCountEachRow
        let cell = tableView.dequeueReusableCell(withIdentifier: "functionCell") as! FunctionCell
        cell.subviews.forEach() { subView in
            subView.removeFromSuperview()
        }
        for i in 0...(buttonCountEachRow - 1) {
            
            if index >= functions.count {
                break
            }
            
            let function = functions[index]
        
            
            if !isNeedMore && function.isMore {
                break
            }
            
            _ = addCellView(row: row, column: i, index: index, function: function, cell: cell)
            index = index + 1
        }
        
        cell.separatorInset = UIEdgeInsetsMake(0, UIScreen.main.bounds.width, 0, 0);
        return cell
    }
    
    
    var cellHeight:CGFloat {
        get {
            let screenWidth = UIScreen.main.bounds.width
            if UIDevice().isIphone4Like() {
                return screenWidth / CGFloat(buttonCountEachRow) * 0.7
            } else {
                return screenWidth / CGFloat(buttonCountEachRow) * 0.92
            }
            
        }
    }
    
    private func addCellView(row : Int, column : Int, index: Int, function: ExtendFunction, cell: UITableViewCell) -> UIView {
        let interval : CGFloat = UIScreen.main.bounds.width / CGFloat(buttonCountEachRow)
        let x = interval  * CGFloat(column)
        let cellView = UIView(frame: CGRect(x: x, y: 0, width: interval, height: 100))
        
        cellView.tag = index
        cell.addSubview(cellView)
        
        let view = ExtendFunctionView(frame: CGRect(x: 0, y: 0, width: interval, height: cellHeight), index: index, function: function, superView: cellView)
        cellView.addSubview(view)
        cellView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: function.action ))
        cellView.isUserInteractionEnabled = true
        
        return cellView
    }
    
    private func redraw(index: Int, view: UIView) {
        let row : Int = index / buttonCountEachRow
        let column : Int = index % buttonCountEachRow
        let parent = view.superview!
        view.removeFromSuperview()
        _ = addCellView(row: row, column: column, index: index, function: functions[index], cell: parent as! UITableViewCell)
    }

    @objc func imageHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!, view:(sender?.view)!)
        let function = functions[index!]
        let params : [String: String] = ["url": function.url, "title": function.name]
        controller.performSegue(withIdentifier: "loadWebPageSegue", sender: params)
    }
    
    @objc func dingyueHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!, view:(sender?.view)!)
        controller.performSegue(withIdentifier: "zhuanLanListSegue", sender: nil)
    }
    
    @objc func jpkHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!, view:(sender?.view)!)
        var sender = [String:String]()
        sender["type"] = ZhuanLanListVC.TYPE_JPK
        controller.performSegue(withIdentifier: "zhuanLanListSegue", sender: sender)
    }
    
    @objc func questionHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!, view:(sender?.view)!)
        controller.performSegue(withIdentifier: "allQuestionsSegue", sender: nil)
    }
    
    func unSupportHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!, view:(sender?.view)!)
        controller.displayMessage(message: "敬请期待")
    }
    
    @objc func moreHanlder(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!,view:(sender?.view)!)
        controller.performSegue(withIdentifier: "moreFunctionSegue", sender: nil)
    }
    
    @objc func openApp(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!, view:(sender?.view)!)

        let jfzfHooks = "com.uen.jfzfxpush://"
        let jfzfUrl = NSURL(string: jfzfHooks)
        if UIApplication.shared.canOpenURL(NSURL(string: jfzfHooks)! as URL)
        {
            UIApplication.shared.openURL(jfzfUrl! as URL)
            
        } else {
            let params : [String: String] = ["url": "http://jf.yhkamani.com/dlios.html", "title": "巨方支付下载"]
            controller.performSegue(withIdentifier: "loadWebPageSegue", sender: params)
        }
    }
    
    @objc func shareHanlder(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!, view:(sender?.view)!)
        
        controller.performSegue(withIdentifier: "codeImageSegue", sender: nil)
    }
    
    @objc func liveClassHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!, view:(sender?.view)!)
        controller.performSegue(withIdentifier: "beforeCourseSegue", sender: CourseType.LiveCourse)
    }
    
    private func clearFunctionMessage(index: Int, view: UIView) {
        
        let function = functions[index]
        function.messageCount = 0
        extendFunctionStore.clearMessage(code: function.code, value: 0)
        let request = ClearFunctionMessageRequest()
        request.code = function.code
        BasicService().sendRequest(url: ServiceConfiguration.CLEAR_FUNCTION_MESSAGE, request: request) {
            (resp: ClearFunctionMessageResponse) -> Void in
            if resp.isFail {
                QL4(resp.errorMessage)
                return
            }
        }
        redraw(index: index, view: view)
    }
}

class ExtendFunction {
    var imageName = ""
    var _name = ""
    var url = ""
    var code = ""
    var isShowDefault = true
    var isSupport = false
    var messageCount = 0
    var action : Selector
    
    var isMore : Bool {
        get {
            return code == "f_more"
        }
    }
    
    var hasMessage: Bool {
        get {
            return self.messageCount > 0
        }
    }
    
    var name: String {
        get {
            //return ExtendFunctionStore.instance.getFunctionName(code: self.code, defaultValue: _name)
            return _name
        }
    }
    
    var imageUrl: String {
        get {
            //return ExtendFunctionStore.instance.getImageUrl(code: self.code)
            return imageName
        }
    }
    
    init(imageName: String, name: String, code: String, url: String, messageCount: Int, selector: Selector, isShowDefault: Bool) {
        self.imageName = imageName
        self._name = name
        self.url = url
        self.action = selector
        self.code = code
        self.isShowDefault = isShowDefault
        self.messageCount = messageCount
    }
    
    func dummy() {
        
    }
    
    init(code: String, isShowDefault: Bool, messageCount: Int) {
        self.code = code
        self.isShowDefault = isShowDefault
        self.messageCount = messageCount
        //TODO:  
        self.action = Selector("")
    }
}
