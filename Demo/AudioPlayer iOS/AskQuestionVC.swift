//
//  AskQuestionVC.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/9/9.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class AskQuestionVC: BaseUIViewController, UITextViewDelegate {
    
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
        contentView.placeholder = "问题内容限制在400字以内"
        
        setLeftBackButton()
    }
    

    @IBAction func askQuestionPressed(_ sender: Any) {
        sendAskQuestion()
    }
    
}

extension AskQuestionVC {
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

extension AskQuestionVC : UIAlertViewDelegate{
    func sendAskQuestion() {
        loading.showOverlay(view: self.view)
        let req = AskQuestionRequest()
        req.content = contentView.text.trimmingCharacters(in: .whitespaces)
        BasicService().sendRequest(url: ServiceConfiguration.ASK_QUESTION, request: req) {
            (resp: AskQuestionResponse) -> Void in
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
