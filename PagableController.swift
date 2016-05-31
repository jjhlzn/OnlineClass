//
//  PagableController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/30.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit

public protocol PagableControllerDelegate : NSObjectProtocol {
    func searchHandler(respHandler: ((resp: ServerResponse) -> Void))
    func refreshHandler(respHandler: ((resp: ServerResponse) -> Void))
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
    
    var refreshControl: UIRefreshControl!
    
    func initController() {
        if isNeedRefresh {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
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
            dispatch_async(dispatch_get_main_queue()) {
                self.afterHandleResponse(resp as! PageServerResponse<T>)
            }
        }
    }
    
    func refresh() {
        if (quering) {
            refreshControl.endRefreshing()
            return
        }
        
        quering = true
        page = 0
        
        delegate.refreshHandler() {
            (resp: ServerResponse) -> Void in
            self.afterHandleRefreshRespones(resp as! PageServerResponse<T>)
        }

    }
    
    func afterHandleRefreshRespones(resp: PageServerResponse<T>) {
        self.quering = false
        refreshControl.endRefreshing()
        
        if resp.status != 0 {
            print("Server Return Error")
            viewController.displayMessage(resp.errorMessage!)
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
        
        if resp.status != 0 {
            print("Server Return Error")
            viewController.displayMessage(resp.errorMessage!)
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
        tableFooterView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 40)
        loadMoreText.frame =  CGRectMake(0, 0, tableView.bounds.size.width, 40)
        
        
        loadMoreText.textAlignment = NSTextAlignment.Center
        tableFooterView.addSubview(loadMoreText)
        loadMoreText.center = CGPointMake( (tableView.bounds.size.width - loadMoreText.intrinsicContentSize().width / 16) / 2 , 20)
        self.setFootText()
        
        tableView.tableFooterView = tableFooterView
    }
    
    func setLoadingFooter() {
        
        self.tableView.tableFooterView = nil
        tableFooterView = UIView()
        tableFooterView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 40)
        loadMoreText.frame =  CGRectMake(0, 0, tableView.bounds.size.width, 40)
        
        
        loadMoreText.textAlignment = NSTextAlignment.Center
        
        
        loadMoreText.center = CGPointMake( (tableView.bounds.size.width - loadMoreText.intrinsicContentSize().width / 16) / 2 , 20)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = CGPointMake( (tableView.bounds.size.width - 80 - loadMoreText.intrinsicContentSize().width / 16) / 2 , 20)
        activityIndicator.startAnimating()
        
        tableFooterView.addSubview(activityIndicator)
        tableFooterView.addSubview(loadMoreText)
        setFootText()
        tableView.tableFooterView = tableFooterView
    }
    
    private func setFootText() {
        
        
        loadMoreText.font = UIFont(name: "Helvetica Neue", size: 10)
        loadMoreText.textColor = UIColor.grayColor()
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