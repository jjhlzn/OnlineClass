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

class QuestionItemCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate, LTTableViewProtocal {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var answersView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var interLine: UIView!
    @IBOutlet weak var answerImage: UIImageView!
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var answerCountLabel: UILabel!
    @IBOutlet weak var thumbCountLabel: UILabel!
    
    var question : Question?
    var tableView = UITableView()
    
    var answerCells = [UITableViewCell]()
    var answerLabels = [UILabel]()
    var isLast = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //answersView.backgroundColor = UIColor.white.withAlphaComponent(1)
        tableView.bounces = false
        tableView.autoresizesSubviews = true
        tableView.register(UINib(nibName:"AnswerCell", bundle:nil),forCellReuseIdentifier:"AnswerCell")
        
        
        //tableView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        //tableView.bounds =  tableView.frame.insetBy(dx: 50.0, dy: 50.0)
        //answersView.bounds = answersView.frame.insetBy(dx: 10.0, dy: 10.0)
    }
    
    func setAnswerTableView() {
        makeAnswerCells()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        
        var height : CGFloat = 0
        for index in 0..<answerCells.count {
            height += (answerCells[index] as! AnswerCell).getHeight()
        }
        var aframe = answersView.frame
        aframe.size.height = height
        aframe.origin.y = getFirstPartHeight()
        answersView.frame = aframe
        
        var tFrame = tableView.frame
        tFrame.size.width = aframe.width
        tFrame.size.height = height
        tableView.frame = tFrame
        answersView.addSubview(tableView)
    }
    
    func update() {
        if isLast {
            
            interLine.isHidden = true
        }
        
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
        makeAnswersView()
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
            makeAnswerCell(answer, origin: origin)
            height += answerLabels[index].frame.height + lineSpace
        }
    
        var aframe = answersView.frame
        aframe.size.height = height
        aframe.origin.y = getFirstPartHeight()
        answersView.frame = aframe
    }
    
    
    private func makeAnswerCell(_ answer: Answer, origin: CGPoint) {
        let label = UILabel(frame: CGRect(x: origin.x + padX, y: origin.y + padY, width: answersView.frame.width -  padX, height: 100))
        
        label.backgroundColor = answersView.backgroundColor
        label.text = makeAnswerContent(answer)
        //var frame = label.frame;
        label.setLineSpacing(lineSpacing: 0, lineHeightMultiple: 1.3)
        label.font = UIFont(name: self.contentLabel.font.fontName,size: 13)
        
        label.numberOfLines = 0
        label.sizeToFit()
        
        //frame.size.height = label.frame.size.height
        answerLabels.append(label)
        
        answersView.addSubview(label)
    }
    
    private func makeAnswerCells() {
        answerCells = [UITableViewCell]()
        for index in 0..<question!.answers.count {
            let cell : AnswerCell = cellWithTableView(tableView)
            cell.answer = question!.answers[index]
            cell.update()
            self.answerCells.append(cell)
        }
    }
    
    private func makeAnswerContent(_ answer : Answer) -> String {
        //设置内容
        var content = answer.fromUserName!
        if answer.toUserName != nil {
            content = content + " 回复 " + answer.toUserName!
        }
        content = content + " : " + answer.content
        return content
    }
    
    public func getHeight() -> CGFloat {
      
        return getFirstPartHeight() + answersView.frame.height + 10
    }
    
    private func getFirstPartHeight() -> CGFloat {
        return 62 + contentLabel.frame.height
    }
    
}

extension QuestionItemCell {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answerCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        return answerCells[row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let cell = answerCells[row] as! AnswerCell
        return cell.getHeight()
    }

}
