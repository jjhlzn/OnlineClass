//
//  PagableController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/30.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit
import QorumLogs

public protocol PagableControllerDelegate : NSObjectProtocol {
    func searchHandler(respHandler: @escaping ((_ resp: ServerResponse) -> Void))
}

class PagableController<T> : NSObject {
    
    var viewController: BaseUIViewController!
    var tableView: UITableView!
    var tableFooterView = UIView()
    var loadMoreText = UILabel()
    var hasMore = true
    var quering = false
    var page = 0
    var isNeedRefresh = true
    var delegate :PagableControllerDelegate!
    var data = [T]()
    var isShowLoadCompleteText = true
    var confirmDelegate : ConfirmDelegate?
    
    var refreshControl: UIRefreshControl!
    
    func initController() {
        confirmDelegate = ConfirmDelegate(controller: viewController)
        if isNeedRefresh {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
            tableView.addSubview(refreshControl)
        }
    }
    
    func reset() {
        data = [T]()
        tableView.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView){
        if quering {
            return
        }
        setFootText()
        if !hasMore {
            return
        }
        
        if scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height ){
            loadMore()
        }
    }
    
    func loadMore() {
        quering = true
        print("loading")
        setLoadingFooter()
        
        delegate.searchHandler() {
            (resp: ServerResponse) -> Void in
            DispatchQueue.main.async() {
                self.afterHandleResponse(resp: resp as! PageServerResponse<T>)
            }
        }
    }
    
    @objc func refresh() {
        if (quering) {
            refreshControl.endRefreshing()
            return
        }
        
        quering = true
        page = 0
        
        delegate.searchHandler() {
            (resp: ServerResponse) -> Void in
            DispatchQueue.main.async() {
                self.afterHandleRefreshRespones(resp: resp as! PageServerResponse<T>)
            }
        }
        
    }
    
    func afterHandleRefreshRespones(resp: PageServerResponse<T>) {
        self.quering = false
        refreshControl.endRefreshing()
        
        if resp.status != 0 {
            print("Server Return Error")
            viewController.displayMessage(message: resp.errorMessage!)
            return
        }
        
        let newDataSet = resp.resultSet
        self.data = newDataSet
        
        print("data.count = \(self.data.count)")
        print("resp.totalNumber = \(resp.totalNumber)")
        if self.data.count >= resp.totalNumber {
            self.hasMore = false
        } else {
            self.hasMore = true
        }
        
        self.page = self.page + 1
        self.setNotLoadFooter()
        self.tableView.reloadData()
        self.setFootText()
    }

    
    
    func afterHandleResponse(resp: PageServerResponse<T>) {
        self.quering = false
        
        //目前这个逻辑之针对VIP课程权限够的情况
        if resp.status == ServerResponseStatus.NoEnoughAuthority.rawValue {
            self.hasMore = false
            QL1(viewController)
            if viewController.view.window != nil {
                viewController.displayVipBuyMessage(message: resp.errorMessage!, delegate: confirmDelegate!)
            } else {
                QL4("can't show alert message on ther view controller")
            }
            return
        }
        
        if resp.status != 0 {
            print("Server Return Error")
            viewController.displayMessage(message: resp.errorMessage!)
            return
        }
        
        let newDataSet = resp.resultSet
        for item in newDataSet {
            self.data.append(item)
        }
        if self.data.count >= resp.totalNumber {
            self.hasMore = false
        } else {
            self.hasMore = true
        }
        
        self.page = self.page + 1
        self.setNotLoadFooter()
        self.tableView.reloadData()
        
        self.setFootText()
    }
    
    private func createTableFooter(){//初始化tv的footerView
        
        setNotLoadFooter()
    }
    
    private func setNotLoadFooter() {
        
        
        self.tableView.tableFooterView = nil
        tableFooterView = UIView()
        tableFooterView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40)
        loadMoreText.frame =  CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40)
        
        
        loadMoreText.textAlignment = NSTextAlignment.center
        tableFooterView.addSubview(loadMoreText)
        loadMoreText.center = CGPoint( x: (tableView.bounds.size.width - loadMoreText.intrinsicContentSize.width / 16) / 2 , y: 20)
        self.setFootText()
        
        tableView.tableFooterView = tableFooterView
    }
    
    func setLoadingFooter() {
        if self.tableView == nil {
            return
        }
        self.tableView.tableFooterView = nil
        tableFooterView = UIView()
        tableFooterView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40)
        loadMoreText.frame =  CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40)
        
        
        loadMoreText.textAlignment = NSTextAlignment.center
        
        
        loadMoreText.center = CGPoint(x: (tableView.bounds.size.width - loadMoreText.intrinsicContentSize.width / 16) / 2 , y: 20)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = CGPoint(x: (tableView.bounds.size.width - 80 - loadMoreText.intrinsicContentSize.width / 16) / 2 , y: 20)
        activityIndicator.startAnimating()
        
        tableFooterView.addSubview(activityIndicator)
        tableFooterView.addSubview(loadMoreText)
        setFootText()
        tableView.tableFooterView = tableFooterView
    }
    
    private func setFootText() {
        
        
        loadMoreText.font = UIFont(name: "Helvetica Neue", size: 10)
        loadMoreText.textColor = UIColor.gray
        if quering {
            self.loadMoreText.text = "加载中"
            
        } else {
            if self.hasMore {
                self.loadMoreText.text = "上拉查看更多"
            } else {
                
                //不显示加载完成的文本
                if !isShowLoadCompleteText {
                    self.loadMoreText.text = ""
                    return
                }
                
                if self.data.count == 0 {
                    loadMoreText.font = UIFont(name: "Helvetica Neue", size: 14)
                    self.loadMoreText.text = "没找到任何数据"
                } else {
                    
                    self.loadMoreText.text = "已加载全部数据"
                }
            }
        }
    }


}

class ConfirmDelegate : NSObject, UIAlertViewDelegate {
    var controller : UIViewController
    var parentController: UIViewController?
    init(controller: UIViewController) {
        self.controller = controller
        QL1(controller.navigationController?.viewControllers)
        let controllers = controller.navigationController?.viewControllers
        if (controllers?.count)! > 1 {
            self.parentController = controller.navigationController?.viewControllers[0]
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            print("button 0 pressed")
            if controller.view.window != nil {
                controller.performSegue(withIdentifier: "buyVipSegue", sender: nil)
            } else {
                //QL1(parentController)
                //if parentController as? CourseMainPageViewController != nil {
                //parentController!.performSegueWithIdentifier("bugVipSegue", sender: nil)
                //}
            }
            break
        case 1:
            print("button 1 pressed")
            controller.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
        
    }
    
}
