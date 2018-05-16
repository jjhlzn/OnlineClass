//
//  SearchCourseViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/29.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class SearchCourseViewController: BaseUIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var searchField: UITextField!

    @IBOutlet weak var searchTipView: UIView!
    
    @IBOutlet weak var searchView: UIView!
    var searchTipViewBackup :UIView?
    
    var loading = LoadingOverlay()
    
    var request : SearchRequest?
    
    var hotSearchKeywords : [String] = []
    
    var pagableController = PagableController<Album>()

}
