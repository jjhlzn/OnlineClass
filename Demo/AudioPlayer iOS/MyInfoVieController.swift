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
import SwiftyBeaver

class MyInfoVieController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    let log = SwiftyBeaver.self
    var thirdSections = [ ["me_tuijian", "我的推荐", "webViewSegue", ServiceLinkManager.MyTuiJianUrl],
                          ["me_order", "我的订单", "webViewSegue", ServiceLinkManager.MyOrderUrl],
                          ["me_team", "我的团队", "webViewSegue", ServiceLinkManager.MyTeamUrl],
                          ["me_tixian", "我要提现","webViewSegue", ServiceLinkManager.MyExchangeUrl],
                       ]
    

    var fourthSections = [ ["me_ziliao", "我的资料", "personalInfoSegue"],
                           ["me_qrcode", "我的二维码", "codeImageSegue"],
                           ]
    
    var fifthSections = [ ["me_agent", "我要申请","webViewSegue", ServiceLinkManager.MyAgentUrl],
                           ]
    
    
    var keyValueStore = KeyValueStore()
    
    var refreshControl: UIRefreshControl!
    var querying = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            //tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)//导航栏如果使用系统原生半透明的，top设置为64
            //tableView.scrollIndicatorInsets = tableView.contentInset
            tableView.contentInset = UIEdgeInsetsMake(23, 0, 49, 0)
            tableView.estimatedRowHeight = 0
            UITableView.appearance().estimatedRowHeight = 0
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    
    @objc func refresh() {
        if (querying) {
            refreshControl.endRefreshing()
            return
        }
        
        querying = true
        
        BasicService().sendRequest(url: ServiceConfiguration.GET_USER_STAT_DATA, request: GetUserStatDataRequest()) {
            (resp: GetUserStatDataResponse) -> Void in
            self.updateUserStatData(resp: resp)
            self.tableView.reloadData()
            self.querying = false
            self.refreshControl.endRefreshing()
        }
    }

    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    var loginUserStore = LoginUserStore()

}

extension MyInfoVieController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        log.debug("section:")
        log.debug(section)
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return thirdSections.count
        case 3:
            return fourthSections.count
        case 4:
            return fifthSections.count

        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        log.debug("section heightForRowAtIndexPath:")
        log.debug(section)
        switch section {
        case 0:
            return 134
        case 1:
            return 71
        case 2:
            return 48
        case 3:
            return 48
        case 4:
            return 48
        default:
            return 1
        }
    }
    
    @objc func userImageTapped(img: AnyObject) {
        performSegue(withIdentifier: "setProfilePhotoSegue", sender: nil)
    }
    
    @objc func userInfoTapped(sender: UITapGestureRecognizer? = nil) {
        let index = (sender?.view?.tag)!
        var link = ServiceLinkManager.MyTeamUrl2
        var title = ""
        switch index {
        case 0:
            link = ServiceLinkManager.MyJifenUrl
            title = "我的积分"
            break
        case 1:
            link = ServiceLinkManager.MyChaifuUrl
            title = "我的财富"
            break
        case 2:
            link = ServiceLinkManager.MyTeamUrl2
            title = "我的团队"
            break
        default:
            break
            
        }
        performSegue(withIdentifier: "webViewSegue2", sender:  [link, title])
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        log.debug("section cellForRowAt:")
        log.debug(section)
        switch section {
        case 0:
            let loginUser : LoginUserEntity = loginUserStore.getLoginUser()!
            let cell = tableView.dequeueReusableCell(withIdentifier: "myInfoMainCell") as! MyInfoMainCell
            
            
            if UserProfilePhotoStore().get() == nil {
                QL1("userName = \(loginUser.userName)")
                let profilePhotoUrl = ServiceConfiguration.GET_PROFILE_IMAGE + "?userid=" + loginUserStore.getLoginUser()!.userName!
                QL1("userimageurl = \(profilePhotoUrl)")
                
                cell.userImage.kf.setImage(with: URL(string: profilePhotoUrl))
                                                  
                /*
                cell.userImage.kf_setImageWithURL(NSURL(string: profilePhotoUrl)!,
                                                  placeholderImage: nil,
                                                  optionsInfo: nil,
                                                  progressBlock: { (receivedSize, totalSize) -> () in
                                                    //print("Download Progress: \(receivedSize)/\(totalSize)")
                                                  },
                                                  completionHandler: { (image, error, cacheType, imageURL) -> () in
                                                    if image != nil {
                                                        UserProfilePhotoStore().saveOrUpdate(image!)
                                                    }
                                                  }) */

            } else {
                cell.userImage.image = UserProfilePhotoStore().get()
            }
            
            
            cell.userImage.becomeCircle()
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(userImageTapped))
            cell.userImage.isUserInteractionEnabled = true
            cell.userImage.addGestureRecognizer(tapGestureRecognizer)
            cell.levelLabel.text = loginUser.level
            cell.bossLabel.text = loginUser.boss
            print("nickname = \(loginUser.nickName!)")
            if loginUser.nickName == nil || loginUser.nickName == "" {
                cell.userInfoLabel.text = "\(loginUser.name!)"
            } else {
                cell.userInfoLabel.text = "\(loginUser.name!) (\(loginUser.nickName!))"
            }

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "myInfoSecondLineCell") as! MyInfoSecondLineCell
            cell.jifenLabel.text = keyValueStore.get(key: KeyValueStore.key_jifen, defaultValue: "0")
            cell.chaifuLabel.text = keyValueStore.get(key: KeyValueStore.key_chaifu, defaultValue: "0")
            cell.tuanduiLabel.text = keyValueStore.get(key: KeyValueStore.key_tuandui, defaultValue: "1人")
            

            cell.jifenView.tag = 0
            cell.jifenView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userInfoTapped)))
            cell.jifenView.isUserInteractionEnabled = true
            
            cell.chaifuView.tag = 1
            cell.chaifuView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userInfoTapped)))
            cell.chaifuView.isUserInteractionEnabled = true
            
            cell.taunduiView.tag = 2
            cell.taunduiView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userInfoTapped)))
            cell.taunduiView.isUserInteractionEnabled = true

            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "myInfoOtherCell") as! MyInfoOtherCell
            let data = thirdSections[row]
            cell.leftImage.image = UIImage(named: data[0])
            cell.titleLabel.text = data[1]
            cell.otherInfoLabel.text  = ""
            switch row {
            case 0:
                cell.otherInfoLabel.text = keyValueStore.get(key: KeyValueStore.key_tuijian, defaultValue: "0人")
                break
            case 1:
                cell.otherInfoLabel.text = keyValueStore.get(key: KeyValueStore.key_ordercount,
                   defaultValue: "0笔")
                break
            case 2:
                cell.otherInfoLabel.text = keyValueStore.get(key: KeyValueStore.key_tuandui, defaultValue: "1人")
            default:
                break
            }
            //发起更新用户数据的请求
            if row == thirdSections.count - 1 {
                BasicService().sendRequest(url: ServiceConfiguration.GET_USER_STAT_DATA, request: GetUserStatDataRequest()) {
                    (resp: GetUserStatDataResponse) -> Void in
                    self.updateUserStatData(resp: resp)
                }
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "myInfoOtherCell") as! MyInfoOtherCell
            let data = fourthSections[row]
            cell.leftImage.image = UIImage(named: data[0])
            cell.titleLabel.text = data[1]
            cell.otherInfoLabel.text  = ""
            return cell

        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "myInfoOtherCell") as! MyInfoOtherCell
            let data = fifthSections[row]
            cell.leftImage.image = UIImage(named: data[0])
            cell.titleLabel.text = data[1]
            cell.otherInfoLabel.text  = ""
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell") as! logoutCell
            cell.viewController = self
            return cell
        }
    }
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)

        let section = indexPath.section
        let row = indexPath.row
        switch section {
            
        case 2:
            performSegue(withIdentifier: thirdSections[row][2], sender: thirdSections[row])
            break
        case 3:
            performSegue(withIdentifier: fourthSections[row][2], sender: thirdSections[row])
            break
        case 4:
            performSegue(withIdentifier: thirdSections[row][2], sender: fifthSections[row])
            break
        default:
            break
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webViewSegue" {
            let data  = sender as! Array<String>
            let dest = segue.destination as! WebPageViewController
            dest.url = NSURL(string: data[3])!
            dest.title = data[1]
        } else if segue.identifier == "webViewSegue2" {
            let data  = sender as! Array<String>
            let dest = segue.destination as! WebPageViewController
            dest.url = NSURL(string: data[0])!
            dest.title = data[1]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        log.debug("numberOfSectionsInTableView:")
        log.debug(5)
        return 5
    }
    
    private func updateUserStatData(resp : GetUserStatDataResponse) {
        if resp.status != ServerResponseStatus.Success.rawValue {
            QL1("getUserStatData return error, \(resp.errorMessage!)")
            return
        }
        
        var indexPath = NSIndexPath(row: 0, section: 1)
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as! MyInfoSecondLineCell
        cell.jifenLabel.text = resp.jifen
        cell.chaifuLabel.text = resp.chaifu
        cell.tuanduiLabel.text = resp.teamPeople
        keyValueStore.save(key: KeyValueStore.key_jifen, value: resp.jifen)
        keyValueStore.save(key: KeyValueStore.key_chaifu, value: resp.chaifu)
        keyValueStore.save(key: KeyValueStore.key_tuandui, value: resp.teamPeople)
        
        indexPath = NSIndexPath(row: 0, section: 2)
        let  cell1 = tableView.cellForRow(at: indexPath as IndexPath) as! MyInfoOtherCell
        cell1.otherInfoLabel.text = resp.tuijianPeople
        keyValueStore.save(key: KeyValueStore.key_tuijian, value: resp.tuijianPeople)
        
        indexPath = NSIndexPath(row: 1, section: 2)
        let cell2 = tableView.cellForRow(at: indexPath as IndexPath) as! MyInfoOtherCell
        cell2.otherInfoLabel.text = resp.orderCount
        keyValueStore.save(key: KeyValueStore.key_ordercount, value: resp.orderCount)
        
        indexPath = NSIndexPath(row: 2, section: 2)
        let cell3 = tableView.cellForRow(at: indexPath  as IndexPath) as! MyInfoOtherCell
        cell3.otherInfoLabel.text = resp.teamPeople
        
        let loginUserStore = LoginUserStore()
        let loginUser = loginUserStore.getLoginUser()!
        loginUser.name = resp.name
        loginUser.nickName = resp.nickName
        loginUser.codeImageUrl = resp.codeImageUrl
        loginUser.level = resp.level
        loginUser.sex = resp.sex
        loginUser.boss = resp.boss
        loginUserStore.updateLoginUser()
        
        //tableView.reloadData()
    
        
    }

}
