//
//  ZhuanLanListVC.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/15.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class ZhuanLanListVC: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var zhuanLans = [ZhuanLan]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            if UIDevice().isX() {
                tableView.contentInset = UIEdgeInsetsMake(24, 0, 49, 0)
            }
            
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        loadZhuanLans()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadZhuanLans() {
        BasicService().sendRequest(url: ServiceConfiguration.Get_ZHUANLAN_LIST, request: GetZhuanLansRequest()) {
            (resp: GetZhuanLansResponse) -> Void in
            
            self.zhuanLans = resp.zhuanLans
            self.tableView.reloadData()
        }
    }
}

extension ZhuanLanListVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return zhuanLans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "zhuanLanCell2") as! ZhuanLanCell2
        let row = indexPath.row
        cell.zhuanLan = zhuanLans[row]
        cell.update()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

