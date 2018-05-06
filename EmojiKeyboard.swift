//
//  EmojiKeyboard.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/1.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import Emoji


// Emoji键盘， 每一个排放7个表情，一个屏幕放4排，每个宽度25
// 25 * 7 = 175  20 * 6 = 120    295  25     25 + 20
// 15   60             
// 45
// (320 - (25 * 7 + 15 * 2)) / 6
class EmojiKeyboard: NSObject {
    
    var editText : UITextView
    
    let emojiKeys = [":smile:", ":laughing:", ":kissing_smiling_eyes:", ":heart_eyes:", ":heart:", ":heartpulse:", ":sparkling_heart:",
                     ":star:", ":fire:", ":thumbsup:", ":ok_hand:", ":v:", ":clap:", ":muscle:",
                     ":kiss:", ":ox:", ":coffee:", ":tea:", ":beers:", ":100:", ":lollipop:",
                     ":tangerine:", ":watermelon:", ":lemon:", ":strawberry:", ":pear:", ":tomato:", ":apple:",
                     ":cherries:", ":peach:", ":pineapple:", ":sunny:", ":sunflower:", ":rose:", ":hibiscus:",]
    
    init(editText: UITextView) {
        self.editText = editText
    }
    
    let size : CGFloat = 30
    let keyboardHeight: Int = 213
    
    var view : UIView?
    
    func getView() -> UIView {
        
        if view != nil {
            return view!
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHight = UIScreen.main.bounds.height
        let frame = CGRect(x: 0, y: Int(screenHight) - keyboardHeight, width: Int(screenWidth), height: keyboardHeight)
        
        let xx = screenWidth - CGFloat((size * 7 + 15 * 2))
        let interval = xx / 6
        
        view = UIView(frame: frame)
        view?.backgroundColor = UIColor.white
        
        var i = 0
        for emojiKey in emojiKeys {
            let row = i / 7
            let column = i % 7
            
            print(" row = \(row), column = \(column)")
            
            let x = 15 + (interval + size) * CGFloat(column)
            let y = Int(10 +  (size + 10)  * CGFloat(row))
            
            print ("x = \(x), y = \(y)")
            
            let emojiFrame = CGRect(x: Int(x), y: y, width: Int(size), height: Int(size))
            let label = UILabel(frame: emojiFrame)
            label.font = label.font.withSize(25)
            label.tag = i
            label.text = emojiKey.emojiUnescapedString
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
            label.addGestureRecognizer(tapGesture)
            label.isUserInteractionEnabled = true
            
            print(label.text)
            view?.addSubview(label)
            
            i = i + 1
        }
        
        return view!
        
    }
    
    private func addTapAction(label: UILabel) {
        
    }
    
    
    @objc func tapAction(sender: UITapGestureRecognizer?) {
        let index = sender?.view?.tag
        editText.text = editText.text! + emojiKeys[index!].emojiUnescapedString
        if editText.delegate != nil {
            editText.delegate?.textViewDidChange!(editText)
        }
    }

}
