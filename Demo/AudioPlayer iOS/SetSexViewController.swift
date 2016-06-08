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
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("sexCell")!
        let row = indexPath.row
        cell.textLabel?.text = sexes[row]
        
        if selectSex == sexes[row] {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectSex = (tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!
        
        for i in 0...sexes.count {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            cell?.accessoryType = .None
        }
        
        
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        tableView.reloadData()
    }
    
    
    private func getSelectSex() -> String {
        for i in 0...sexes.count {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            if cell?.accessoryType == .Checkmark {
                return sexes[i]
            }
        }
        return "保密"
    }
    
    
    @IBAction func savePressed(sender: AnyObject) {
        loading.showOverlay(view)
        let request = SetSexRequest()
        request.newSex = getSelectSex()
        BasicService().sendRequest(ServiceConfiguration.SET_SEX, request: request) {
            (resp: SetSexResponse) -> Void in
            self.loading.hideOverlayView()
            if resp.status != 0 {
                self.displayMessage(resp.errorMessage!)
                return
            }
            
            let loginUser = self.loginUserStore.getLoginUser()!
            loginUser.sex = request.newSex
            if self.loginUserStore.updateLoginUser() {
                let viewControllers = (self.navigationController?.viewControllers)!
                (viewControllers[1] as! PersonalInfoViewController).tableView.reloadData()
                self.navigationController?.popViewControllerAnimated(true)
                
            } else {
                self.displayMessage("保存失败")
            }
        }
    }

}
