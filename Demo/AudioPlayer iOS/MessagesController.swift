//
//  MessagesController.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/10/21.
//  Copyright © 2018 tbaranes. All rights reserved.
//

import UIKit
import MJRefresh
import QorumLogs

class MessagesController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    

    @IBOutlet weak var tableView: UITableView!
    var loadingOverlay : LoadingOverlay!
    let refreshHeader = MJRefreshNormalHeader()
    var messages : [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingOverlay = LoadingOverlay()
        // Do any additional setup after loading the view.
        Utils.setNavigationBarAndTableView(self, tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        refreshHeader.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        tableView.mj_header = refreshHeader
        refreshHeader.lastUpdatedTimeLabel.isHidden = true
        refreshHeader.stateLabel.isHidden = true
        setLeftBackButton()
        loadingOverlay.showOverlay(view: self.view)
        loadMessage()
    }
    
    @objc func refresh() {
        loadMessage()
    }
    
    func loadMessage() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_MESSAGES, request: GetMessagesRequest()) {
            (resp : GetMessagesResponse) -> Void in
            self.loadingOverlay.hideOverlayView()
            self.refreshHeader.endRefreshing()
            if resp.isFail {
                QL4(resp.errorMessage)
                return
            }
            self.messages = resp.messages
            self.tableView.reloadData()
        }
    }
}

extension MessagesController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
    
        QL1("heightForRowAt: \(row)")
        return messages[row].height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
        cell.message = messages[row]
        cell.update()
        QL1("cellForRowAt: \(row)")
        messages[row].height = cell.getHeight()
        return cell
    }
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        let row = indexPath.row
        var sender = [String:String]()
        sender["title"] = messages[row].clickTitle
        sender["url"] = messages[row].clickUrl
        performSegue(withIdentifier: "webSegue", sender: sender)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webSegue" {
            let data  = sender as! [String:String]
            let dest = segue.destination as! WebPageViewController
            dest.url = NSURL(string: data["url"]!)!
            dest.title = data["title"]
        }
    }
}
