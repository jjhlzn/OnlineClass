//
//  QuestionListVC.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/9/9.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs
import LTScrollView

class QuestionListVC: BaseUIViewController, LTTableViewProtocal,
    UITableViewDataSource, UITableViewDelegate, PagableControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pagableController = PagableController<Question>()
    var loadingOverlay = LoadingOverlay()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName:"QuestionItemCell", bundle:nil),forCellReuseIdentifier:"QuestionItemCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        //初始化PagableController
        pagableController.viewController = self
        pagableController.delegate = self
        pagableController.tableView = tableView
        pagableController.isNeedRefresh = true
        pagableController.initController()
        pagableController.isShowLoadCompleteText = false
        pagableController.loadMore()
        
        Utils.setNavigationBarAndTableView(self, tableView: tableView)
        
        setLeftBackButton()
    }

    //PageableControllerDelegate
    func searchHandler(respHandler: @escaping ((_ resp: ServerResponse) -> Void)) {
        let request = GetPagedQuestionsRequest()
        request.pageNo = pagableController.page
        BasicService().sendRequest(url: ServiceConfiguration.GET_PAGED_QUESTIONS, request: request,
                                   completion: respHandler as ((_ resp: GetPagedQuestionsResponse) -> Void))
        
    }

    //开始上拉到特定位置后改变列表底部的提示
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        pagableController.scrollViewDidScroll(scrollView: scrollView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "answerQuestionSegue" {
            let args = sender as! [String:AnyObject]
            let dest = segue.destination as! AnswerQuestionVC
            dest.toUserId = args["toUserId"] as? String
            dest.toUserName = args["toUserName"] as? String
            dest.question = args["question"] as? Question
        }
    }
    
    @IBAction func askQuestionPressed(_ sender: Any) {
        DispatchQueue.main.async { () -> Void in
            self.performSegue(withIdentifier: "askQuestionSegue", sender: nil)
        }
    }
    
    
}

extension QuestionListVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pagableController.data.count == 0 {
            return 0
        }
        return pagableController.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let questionItemCell : QuestionItemCell = cellWithTableView(tableView)
        let quesitons = pagableController.data
        questionItemCell.question = quesitons[index]
        questionItemCell.viewController = self
        questionItemCell.update()
        return questionItemCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAt: indexPath) as! QuestionItemCell
        return cell.getHeight()
    }
}
