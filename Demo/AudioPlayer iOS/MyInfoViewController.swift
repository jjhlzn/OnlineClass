//
//  MyInfoVieController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/22.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs
import Kingfisher
import MJRefresh

class MyInfoLineInfo {
    
}

class MyInfoVieController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    var navigationManager : NavigationBarManager!
    
    let refreshHeader = MJRefreshNormalHeader()
    
    var fourthSections = [
        ["me_wallet", "我的钱包", "webViewSegue", ServiceLinkManager.MyWalletUrl, "1", KeyValueStore.key_zhidian] ,
        ["me_service", "我的服务", "webViewSegue", ServiceLinkManager.MyServiceUrl, "0", ""] ]
    
    var fifthSections = [ ["me_agent", "邀请好友", "codeImageSegue", "",  "1", ""],
                          ["me_tuijian", "我的推荐", "webViewSegue", ServiceLinkManager.MyTuiJianUrl,  "1", KeyValueStore.key_tuijian],
                          ["me_order", "我的订单", "webViewSegue", ServiceLinkManager.MyOrderUrl,  "1", KeyValueStore.key_ordercount],
                          ["me_team", "我的团队", "webViewSegue", ServiceLinkManager.MyTeamUrl,  "0", KeyValueStore.key_tuandui],
                        ]
    

    var sixthSections = [ ["me_ziliao", "我的资料", "personalInfoSegue", "",  "1", ""],
                           ["me_qrcode", "我的二维码", "codeImageSegue", "",  "1", ""],
                           ["me_hezuo", "申请合作", "webViewSegue", ServiceLinkManager.HezuoUrl, "0", ""],
                        ]
    
    var seventhSections = [ ["me_settings", "设置","settingsSegue", "",  "0", ""],
                           ]
    var lineSections : [[[String]]]!
    
    
    var keyValueStore = KeyValueStore()
    var loginUserStore = LoginUserStore()
    
    //var refreshControl: UIRefreshControl!
    var querying = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationManager = NavigationBarManager(self)
        
        lineSections = [[[String]]]()
        lineSections.append(fourthSections)
        lineSections.append(fifthSections)
        lineSections.append(sixthSections)
        lineSections.append(seventhSections)
        
        Utils.setNavigationBarAndTableView(self, tableView: tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        refreshHeader.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        tableView.mj_header = refreshHeader
        refreshHeader.lastUpdatedTimeLabel.isHidden = true
        refreshHeader.stateLabel.isHidden = true
        
    }
    
    
    @objc func refresh() {
        if (querying) {
            refreshHeader.endRefreshing()
            return
        }
        loadUserData()
    }
    
    func loadUserData() {
        querying = true
        BasicService().sendRequest(url: ServiceConfiguration.GET_USER_STAT_DATA, request: GetUserStatDataRequest()) {
            (resp: GetUserStatDataResponse) -> Void in
            self.updateUserStatData(resp: resp)
            self.tableView.reloadData()
            self.querying = false
            self.refreshHeader.endRefreshing()
        }
    }
    
    
    func setNavigationBar() {
        self.navigationItem.rightBarButtonItems = []
        navigationManager.setMusicButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        loadUserData()
    }

}

extension MyInfoVieController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return fourthSections.count
        case 3:
            return fifthSections.count
        case 4:
            return sixthSections.count
        case 5:
            return seventhSections.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return 88
        case 1:
            return 120

        default:
            return 50
        }
    }
    
    @objc func userImageTapped(img: AnyObject) {
        performSegue(withIdentifier: "setProfilePhotoSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "myInfoFirstSection") as! MyInfoFirstSectionCell
            cell.controller = self
            cell.update()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "myInfoSecondSection") as! MyInfoSecondSectionCell
            cell.controller = self
            cell.update()
            return cell
            
        /*
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "myInfoThirdSection") as! MyInfoThirdSectionCell
            cell.controller = self
            cell.update()
            return cell */


        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "myInfoCommonCell") as! MyInfoCommonCell
            QL1("section: \(section), row: \(row)" )
            cell.lineInfo = lineSections[section - 2][row]
            cell.update()
            return cell
        }
    }
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)

        let section = indexPath.section
        let row = indexPath.row
        if section > 1 {
            let lineInfo = lineSections[section - 2][row]
            if lineInfo[2] == "webViewSegue" {
                var sender = [String:String]()
                sender["title"] = lineInfo[1]
                sender["url"] = lineInfo[3]
                QL1(lineInfo[3])
                performSegue(withIdentifier: lineInfo[2], sender: sender)
            } else {
                performSegue(withIdentifier: lineInfo[2], sender: nil)
            }
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.5
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webViewSegue" {
            let data  = sender as! [String:String]
            let dest = segue.destination as! WebPageViewController
            dest.url = NSURL(string: data["url"]!)!
            dest.title = data["title"]
        } else if segue.identifier == "webViewSegue2" {
            let data  = sender as! Array<String>
            let dest = segue.destination as! WebPageViewController
            dest.url = NSURL(string: data[0])!
            dest.title = data[1]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    private func updateUserStatData(resp : GetUserStatDataResponse) {
        if resp.status != ServerResponseStatus.Success.rawValue {
            QL1("getUserStatData return error, \(resp.errorMessage!)")
            return
        }
        
        keyValueStore.save(key: KeyValueStore.key_jifen, value: resp.jifen)
        keyValueStore.save(key: KeyValueStore.key_chaifu, value: resp.chaifu)
        keyValueStore.save(key: KeyValueStore.key_tuandui, value: resp.teamPeople)
        
        
        keyValueStore.save(key: KeyValueStore.key_tuijian, value: resp.tuijianPeople)
        
        keyValueStore.save(key: KeyValueStore.key_ordercount, value: resp.orderCount)
        keyValueStore.save(key: KeyValueStore.key_zhidian, value: "\(resp.zhidian)知点")
        
        let loginUserStore = LoginUserStore()
        let loginUser = loginUserStore.getLoginUser()!
        loginUser.name = resp.name
        loginUser.nickName = resp.nickName
        loginUser.codeImageUrl = resp.codeImageUrl
        loginUser.level = resp.level
        loginUser.sex = resp.sex
        loginUser.boss = resp.boss
        loginUserStore.updateLoginUser()
        
        tableView.reloadData()
    
        
    }

}
