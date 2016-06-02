//
//  TestController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/1.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import EmojiKit
import Emoji 

class TestController: UIViewController {
    
    
    @IBOutlet weak var editText: UITextField!
    @IBOutlet weak var label: UILabel!
    
    var emojiKeyboard : EmojiKeyboard!
    
    override func viewDidLoad() {
        

        
       // view.addSubView(label)
        
        //let fetcher = EmojiFetcher()
        /*
        fetcher.query("food") { emojiResults in
            for emoji in emojiResults {
                print("Current Emoji: \(emoji.character) \(emoji.name)")
                self.label.text = "\(emoji.character)"
            }
        }
        
        fetcher.query("face") { emojiResults in
            for emoji in emojiResults {
                print("Current Emoji: \(emoji.character) \(emoji.name)")
                self.label.text = "\(emoji.character)"
            }
        }*/
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        label.addGestureRecognizer(tapGesture)
        label.userInteractionEnabled = true
        
        
        
        //emojiKeyboard = EmojiKeyboard(editText: editText)
        //view.addSubview(emojiKeyboard.getView())


    }
    
    func tapAction() {
        print("tapAction")
    }

}
