//
//  ConfigurationController.swift
//  ContractApp
//
//  Created by 刘兆娜 on 16/5/6.
//  Copyright © 2016年 金军航. All rights reserved.
//

import UIKit
import QorumLogs

class ConfigurationController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let names = [["协议", "http 后者 https"], ["服务器", "服务器地址"], ["端口号", "端口号"], ["是否使用ServiceLocator", ""]]
    var values = ["", "", "", ""]
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
            if serviceLoator?.isUseServiceLocator == nil || serviceLoator?.isUseServiceLocator == "1" {
                values[3] = "1"
            } else {
                values[3] = "0"
            }
            QL1("serviceLocator: \(values[0]) \(values[1]) \(values[2]) \(values[3])")
        } else {
            QL1("servicelocator is null")
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        if row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "configurationCell2") as! ConfigurationCell2
            cell.nameInfoLabel?.text = names[indexPath.row][0]
            cell.switchButton.isOn = values[row] == "1"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "configurationCell") as! ConfigurationCell
            cell.nameInfoLabel?.text = names[indexPath.row][0]
            cell.editView.placeholder = names[indexPath.row][1]
            cell.editView.text = values[indexPath.row]
            return cell

        }
        
    }
    
    
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    @IBAction func savePressed(sender: UIBarButtonItem) {
        //TODO 检查服务器设置是否正确
        
        let http = (tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as!ConfigurationCell).editView.text!
        let serverName = (tableView.cellForRow(at: NSIndexPath(row: 1, section: 0) as IndexPath) as!ConfigurationCell).editView.text!
        let port = (tableView.cellForRow(at: NSIndexPath(row: 2, section: 0) as IndexPath) as!ConfigurationCell).editView.text!
        let isUseServiceLocator = (tableView.cellForRow(at: NSIndexPath(row: 3, section: 0) as IndexPath) as! ConfigurationCell2).switchButton.isOn ? "1" : "0"
        
        if Int(port) == nil {
            displayMessage(message: "端口号必须为数字")
            return
        }
        
        if http != "http" && http != "https" {
            displayMessage(message: "协议必须为http或https")
            return
        }
        
        let serviceLocator = serviceLocatorStore.GetServiceLocator()

        serviceLocator?.http = http
        serviceLocator?.port = Int(port) as! NSNumber
        serviceLocator?.serverName = serverName
        serviceLocator?.isUseServiceLocator = isUseServiceLocator
        
        QL1("newServiceLocator: \(http) \(port) \(serverName) \(isUseServiceLocator)")
        
        if serviceLocatorStore.UpdateServiceLocator() {
            displayMessage(message: "保存成功", delegate: self)
        } else {
            displayMessage(message: "保存失败")
        }
        
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    
    
    
}
