//
//  QuestionItemCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/9/7.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs
import LTScrollView

class QuestionItemCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var answersView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var interLine: UIView!
    @IBOutlet weak var answerImage: UIImageView!
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var answerCountLabel: UILabel!
    @IBOutlet weak var thumbCountLabel: UILabel!
    @IBOutlet weak var headImageView: UIImageView!
    
    var viewController : BaseUIViewController?
    var question : Question?
    
    var answerLabels = [UILabel]()
    var isLast = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }
    
    @objc func tapAnswerQuestionImage() {
        var params = [String:AnyObject]()
        params["toUserId"] = "" as AnyObject
        params["toUserName"] = ""  as AnyObject
        params["question"] = question!  as AnyObject
        viewController?.performSegue(withIdentifier: "answerQuestionSegue", sender: params)
    }
    @objc func tapThumbImage() {
        sendLikeQuestion()
    }
    
    private func initView() {
        answerImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAnswerQuestionImage)))
        answerImage.isUserInteractionEnabled = true
        
        thumbImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapThumbImage)))
        thumbImage.isUserInteractionEnabled = true
    }
    
    
    func update() {
        
        answerLabels = [UILabel]()
        
        if isLast {
            interLine.isHidden = true
        }
        
        Utils.setUserHeadImageView(headImageView, userId: question!.userId)
        
        userNameLabel.text = question!.userName
        timeLabel.text = question!.time
        contentLabel.text = question!.content
        answerCountLabel.text = "\(question!.answerCount!)"
        thumbCountLabel.text = "\(question!.thumbCount!)"
        
        if question!.isLiked {
            thumbImage.image = UIImage(named: "thumb_s")
        } else {
            thumbImage.image = UIImage(named: "thumb")
        }
        
        var frame = contentLabel.frame;
        contentLabel.setLineSpacing(lineSpacing: 0, lineHeightMultiple: 1.4)
        contentLabel.numberOfLines = 0
        contentLabel.sizeToFit()
        frame.size.height = contentLabel.frame.size.height + 10 //10时间隔
        contentLabel.frame = frame

        //setAnswerTableView()
        if question!.answers.count > 0 {
            answersView.isHidden = false
            makeAnswersView()
        } else {
            answersView.isHidden = true
        }
    }
    
    let padX : CGFloat = 6, padY : CGFloat = 2, lineSpace : CGFloat = 2
    private func makeAnswersView() {
        var origin = CGPoint(x: 0, y: 0)
        var height : CGFloat = padY * 2
        for index in 0..<question!.answers.count {
            let answer = question!.answers[index]
            if index != 0 {
                let last = answerLabels[index - 1]
                origin = CGPoint(x: origin.x, y: origin.y + lineSpace + last.frame.height)
            }
            makeAnswerCell(answer, index: index, origin: origin)
            height += answerLabels[index].frame.height + lineSpace
        }
    
        var aframe = answersView.frame
        aframe.size.height = height
        aframe.origin.y = getFirstPartHeight()
        answersView.frame = aframe
    }
    
    
    @objc func tapAnswerLabel(_ sender: UITapGestureRecognizer) {
        let index = (sender.view?.tag)!
        let answer = question!.answers[index]
        var params = [String:AnyObject]()
        params["toUserId"] = answer.fromUserId as AnyObject
        params["toUserName"] = answer.fromUserName  as AnyObject
        params["question"] = question!  as AnyObject
        viewController?.performSegue(withIdentifier: "answerQuestionSegue", sender: params)
        
    }
    
    private func makeAnswerCell(_ answer: Answer, index: Int, origin: CGPoint) {
        let label = UILabel(frame: CGRect(x: origin.x + padX, y: origin.y + padY, width: answersView.frame.width -  padX, height: 100))
        
        label.backgroundColor = answersView.backgroundColor
        label.text = makeAnswerContent(answer)
        //var frame = label.frame;
        label.setLineSpacing(lineSpacing: 0, lineHeightMultiple: 1.3)
        label.font = UIFont(name: self.contentLabel.font.fontName,size: 13)
        
        label.numberOfLines = 0
        label.sizeToFit()
        
        label.tag = index
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAnswerLabel)))
        label.isUserInteractionEnabled = true
        
        //frame.size.height = label.frame.size.height
        answerLabels.append(label)
        
        answersView.addSubview(label)
    }

    
    private func makeAnswerContent(_ answer : Answer) -> String {
        //设置内容
        var content = answer.fromUserName!
        if answer.toUserName != nil &&  answer.toUserName != "" {
            content = content + " 回复 " + answer.toUserName!
        }
        content = content + " : " + answer.content
        return content
    }
    
    public func getHeight() -> CGFloat {
        
        if question!.answers.count > 0 {
            return getFirstPartHeight() + answersView.frame.height + 10
        } else {
            return getFirstPartHeight() + 4
        }
        
    }
    
    private func getFirstPartHeight() -> CGFloat {
        return 62 + contentLabel.frame.height
    }
    
    
    private func sendLikeQuestion() {
        let req = LikeQuestionRequest()
        req.question = question!
        BasicService().sendRequest(url: ServiceConfiguration.LIKE_QUESTION, request: req) {
            (resp: LikeQuestionResponse) -> Void in

            if resp.isSuccess {
                self.thumbImage.image = UIImage(named: "thumb_s")
                self.question?.thumbCount = (self.question?.thumbCount!)! + 1
                self.thumbCountLabel.text = "\((self.question?.thumbCount)!)"
            } else {
                //self.viewController?.displayMessage(message: resp.errorMessage!)
                return
            }
            
        }
    }
}

