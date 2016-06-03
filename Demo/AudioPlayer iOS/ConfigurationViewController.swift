//
//  ConfigurationController.swift
//  ContractApp
//
//  Created by 刘兆娜 on 16/5/6.
//  Copyright © 2016年 金军航. All rights reserved.
//

import UIKit

class ConfigurationController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let names = [["协议", "http 后者 https"], ["服务器", "服务器地址"], ["端口号", "端口号"]]
    var values = ["", "", ""]
    let serviceLocatorStore = ServiceLocatorStore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let serviceLoator = serviceLocatorStore.GetServiceLocator()
        if serviceLoator != nil {
            values[0] = (serviceLoator?.http)!
            values[1] = (serviceLoator?.serverName)!
            values[2] = "\((serviceLoator?.port)!)"
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("configurationCell") as! ConfigurationCell
        cell.nameInfoLabel?.text = names[indexPath.row][0]
        cell.editView.placeholder = names[indexPath.row][1]
        cell.editView.text = values[indexPath.row]
        
        return cell
    }
    
    
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("loginSegue", sender: nil)
    }
    
    @IBAction func savePressed(sender: UIBarButtonItem) {
        //TODO 检查服务器设置是否正确
        
        let http = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as!ConfigurationCell).editView.text!
        let serverName = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as!ConfigurationCell).editView.text!
        let port = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as!ConfigurationCell).editView.text!
        
        if Int(port) == nil {
            displayMessage("端口号必须为数字")
            return
        }
        
        if http != "http" && http != "https" {
            displayMessage("协议必须为http或https")
            return
        }
        
        let serviceLocator = serviceLocatorStore.GetServiceLocator()
        if serviceLocator == nil {
            let new = ServiceLocator()
            new.http = http
            new.port = Int(port)
            new.serverName = serverName
            if serviceLocatorStore.saveServiceLocator(new) {
                displayMessage("保存成功", delegate: self)
            } else {
                displayMessage("保存失败")
            }
        } else {
            serviceLocator?.http = http
            serviceLocator?.port = Int(port)
            serviceLocator?.serverName = serverName
            if serviceLocatorStore.UpdateServiceLocator() {
                displayMessage("保存成功", delegate: self)
            } else {
                displayMessage("保存失败")
            }
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        performSegueWithIdentifier("loginSegue", sender: nil)
    }
    
    
    
    
}
