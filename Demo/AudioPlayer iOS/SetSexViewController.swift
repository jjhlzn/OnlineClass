//
//  SetSexViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/8.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class SetSexViewController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var loginUserStore = LoginUserStore()
    var loading = LoadingOverlay()
    
    var sexes = ["男", "女", "保密"]
    
    var selectSex = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        if loginUserStore.getLoginUser()!.sex == nil {
            selectSex = "保密"
        } else {
            selectSex = loginUserStore.getLoginUser()!.sex!
        }
        
        Utils.setNavigationBarAndTableView(self, tableView: tableView)
        setLeftBackButton()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "sexCell")!
        let row = indexPath.row
        cell.textLabel?.text = sexes[row]
        
        if selectSex == sexes[row] {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectSex = (tableView.cellForRow(at: indexPath as IndexPath)?.textLabel?.text)!
        
        for i in 0...sexes.count {
            let cell = tableView.cellForRow(at: NSIndexPath(row: i, section: 0) as IndexPath)
            cell?.accessoryType = .none
        }
        
        
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    
    private func getSelectSex() -> String {
        for i in 0...sexes.count {
            let cell = tableView.cellForRow(at: NSIndexPath(row: i, section: 0) as IndexPath)
            if cell?.accessoryType == .checkmark {
                return sexes[i]
            }
        }
        return "保密"
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        loading.showOverlay(view: view)
        let request = SetSexRequest()
        request.newSex = getSelectSex()
        BasicService().sendRequest(url: ServiceConfiguration.SET_SEX, request: request) {
            (resp: SetSexResponse) -> Void in
            self.loading.hideOverlayView()
            if resp.status != 0 {
                self.displayMessage(message: resp.errorMessage!)
                return
            }
            
            let loginUser = self.loginUserStore.getLoginUser()!
            loginUser.sex = request.newSex
            if self.loginUserStore.updateLoginUser() {
                let viewControllers = (self.navigationController?.viewControllers)!
                (viewControllers[1] as! PersonalInfoViewController).tableView.reloadData()
                self.navigationController?.popViewController(animated: true)
                
            } else {
                self.displayMessage(message: "保存失败")
            }
        }
    }
    

}
