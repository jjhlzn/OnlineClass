//
//  AnswerQuestionVC.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/9/9.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class AnswerQuestionVC: BaseUIViewController, UITextViewDelegate {
    
    var toUserId : String?
    var toUserName : String?
    var question: Question?
    var loading: LoadingOverlay!
 
    @IBOutlet weak var contentView: UITextViewPlaceHolder!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading = LoadingOverlay()
        contentView.text = ""
        textViewDidChange(contentView)
        contentView.becomeFirstResponder()
        contentView.delegate = self
        if toUserId == nil || toUserId == "" {
            contentView.placeholder = "回复内容限制在200字以内"
        } else {
            contentView.placeholder = "回复\(toUserName!): 内容限制在200字以内"
        }
    }
    
    @IBAction func closePressed(_ sender: Any) {
        DispatchQueue.main.async { () -> Void in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        sendAnswer()
    }
    

}

extension AnswerQuestionVC {
    public func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        if textView.text == "" {
            sendButton.isEnabled = false
            sendButton.tintColor = UIColor.lightGray
        } else {
            sendButton.isEnabled = true
            sendButton.tintColor = Utils.hexStringToUIColor(hex: "#FDAC09")
        }
    }
}

extension AnswerQuestionVC : UIAlertViewDelegate{
    func sendAnswer() {
        loading.showOverlay(view: self.view)
        let req = SendAnswerRequest()
        req.question = question!
        req.content = contentView.text.trimmingCharacters(in: .whitespaces)
        req.toUser = toUserId!
        BasicService().sendRequest(url: ServiceConfiguration.SEND_ANSWER, request: req) {
            (resp: SendAnswerResponse) -> Void in
            self.loading.hideOverlayView()
            if resp.isSuccess {
                self.displayMessage(message: "发送成功，需要审核通过才能查看！", delegate: self)
               
            } else {
                self.displayMessage(message: resp.errorMessage!)
                return
            }

        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
          self.navigationController?.popViewController(animated: true)
    }
}
