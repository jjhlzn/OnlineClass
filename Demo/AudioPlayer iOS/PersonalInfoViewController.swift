//
//  PersonalInfoViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/28.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class PersonalInfoViewController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var loginUserStore : LoginUserStore!
    var loginUser : LoginUserEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        Utils.setNavigationBarAndTableView(self, tableView: tableView)
        setLeftBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loginUserStore = LoginUserStore()
        loginUser = loginUserStore.getLoginUser()!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        (self.navigationController?.viewControllers[0] as! MyInfoVieController).tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "姓名"
            cell.valueLabel.text = loginUser.name
            return cell
        
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "昵称"
            cell.valueLabel.text = loginUser.nickName
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "性别"
            if loginUser.sex == nil {
                cell.valueLabel.text = "保密"
            } else {
                cell.valueLabel.text = loginUser.sex!
            }
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalItemCell") as! PersonalInfoCell
            cell.nameLabel.text = "更多"
            cell.valueLabel.text = ""
            return cell
        
        default:
            return tableView.dequeueReusableCell(withIdentifier: "personalItemCell")!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        DispatchQueue.main.async { () -> Void in
            switch row {
            case 0:
                self.performSegue(withIdentifier: "setNameSegue", sender: nil)
                break
            case 1:
                self.performSegue(withIdentifier: "setNickNameSegue", sender: nil)
                break
            case 2:
                self.performSegue(withIdentifier: "setSexSegue", sender: nil)
                break
            case 3:
                self.performSegue(withIdentifier: "moreSegue", sender: nil)
                break
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "moreSegue" {
            let dest = segue.destination as! WebPageViewController
            dest.title = "个人资料"
            dest.url = NSURL(string: ServiceLinkManager.PersonalInfoUrl)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    
}
