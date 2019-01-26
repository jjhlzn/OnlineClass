//
//  LearnFinanceListController.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/11/28.
//  Copyright © 2018 tbaranes. All rights reserved.
//

import UIKit

class LearnFinanceListController: BaseUIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var learnFinanceItems = [LearnFinanceItem]()
    
    var navigationManager : NavigationBarManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLeftBackButton()
        
        navigationManager = NavigationBarManager(self)
        Utils.setNavigationBarAndTableView(self, tableView: tableView)
        
        //setBackButton()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        loadLearnFinances()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //(self.navigationController?.viewControllers[0] as! CourseMainPageViewController).tableView.reloadData()
    }
    
    func loadLearnFinances() {
        let req = GetLearnFinancesRequest()
        BasicService().sendRequest(url: ServiceConfiguration.GET_LEARN_FINANCES, request: req) {
            (resp: GetlearnFinancesResponse) -> Void in
            
            self.learnFinanceItems = resp.learnFinanceItems
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        //updateViewConstraints()
    }
    
    func setNavigationBar() {
        self.navigationItem.rightBarButtonItems = []
        navigationManager.setMusicButton()
    }
}

extension LearnFinanceListController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return learnFinanceItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "learnFinanceCell") as! LearnFinanceCell
        let row = indexPath.row
        cell.learnFinanceItem = learnFinanceItems[row]
        cell.update()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        let row = indexPath.row
        let learnFinance = learnFinanceItems[row]
        Utils.playLearnFinanceItem(learnFinance)
        tableView.reloadData()
    }

}
