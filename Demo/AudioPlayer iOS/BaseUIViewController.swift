//
//  BaseUIViewController.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/4/16.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer
import QorumLogs


class BaseUIViewController: UIViewController, AudioPlayerDelegate, UIGestureRecognizerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        getAudioPlayer().delegate = self
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        
        if  self.navigationController != nil {
            self.navigationController?.navigationBar.barTintColor =
   UIColor(red: 0xFF/255, green: 0xFF/255, blue: 0xFF, alpha: 0.8)
            self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    
    
    func isNeedResetAudioPlayerDelegate() -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBar0(false)
    }
    
    func setNavigationBar0(_ isTranslucent : Bool) {
        
        
        if self.navigationController?.backdropImageView == nil {
            self.navigationController?.backdropImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 315, height: Utils.getNavigationBarHeight()))
        }
       
        
        if isTranslucent {
            self.navigationController?.setBarColor(image: UIImage(), color: nil, alpha: 0)
        } else {
            self.navigationController?.setBarColor(image: UIImage(), color: UIColor.white, alpha: 1)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        getAudioPlayer().delegate = nil
        
        if isNeedResetAudioPlayerDelegate()
            && self.navigationController?.viewControllers.index(of: self) == nil {
            if let navigatoinViewController = (self.parent as? UINavigationController) {
                if let delegate = navigatoinViewController.topViewController as? AudioPlayerDelegate {
                    getAudioPlayer().delegate = delegate
                }
            }
        }

    }
    
    @objc func _backPressed() {
        DispatchQueue.main.async { () -> Void in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setLeftBackButton() {
        let b = UIButton(frame: CGRect(x: -20, y: 0, width: 24, height: 24))
        b.setImage( UIImage(named: "backicon"), for: .normal)
        let leftButton = UIBarButtonItem(image: UIImage(named: "backicon"), style: .plain, target: self, action: #selector(self._backPressed))
        
       // leftButton.image = UIImage(named: "backicon")
        leftButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem  = leftButton
        
        //self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //关闭左滑关闭
        return false
    } 
    
    func getAudioPlayer() -> AudioPlayer {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.audioPlayer
    }
    
    func addPlayingButton(button: UIButton) {
        button.addTarget(self, action: #selector(playingButtonPressed), for: .touchUpInside)
    }
    
    @objc func playingButtonPressed(sender: UIButton) {
        if hasCurrentItem() {
            DispatchQueue.main.async { () -> Void in
                self.performSegue(withIdentifier: "songSegue", sender: false)
            }
        }
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
    }
    
    private func hasCurrentItem() -> Bool {
        return getAudioPlayer().currentItem != nil
    }
    
    func updatePlayingButton(button: UIButton) {
        let audioPlayer = getAudioPlayer()
        QL1("audioPlayer.state = \(audioPlayer.state)")
        if audioPlayer.state == AudioPlayerState.playing {
            
            let image = UIImage.animatedImage(with: [UIImage(named: "wave1")!,
                UIImage(named: "wave2")!,
                UIImage(named: "wave3")!,
                UIImage(named: "wave4")!,
                UIImage(named: "wave5")!], duration: TimeInterval(0.8))
            button.setImage(image, for: [])
        } else {
            button.setImage(UIImage(named: "wave1"), for: [])
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        QL1("audioPlayer:didChangeStateFrom called, from: \(from), to: \(state)")
    }

    
    func becomeLineBorder(field: UITextField) {
        field.borderStyle = .none
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: field.frame.size.height - 1, width: field.frame.size.width, height: 1.0);
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
        field.layer.addSublayer(bottomBorder)
    }
    
    func setTextFieldHeight(field: UITextField, height: CGFloat) {
        var frameRect = field.frame
        frameRect.size.height = height
        field.frame = frameRect
    }

   
    var tap: UITapGestureRecognizer!
}

extension BaseUIViewController {
    func displayMessage(message : String) {
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButton(withTitle: "好的")
        alertView.cancelButtonIndex=0
        alertView.show()
        
    }
    
    func displayMessage(message : String, delegate: UIAlertViewDelegate) {
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButton(withTitle: "好的")
        alertView.cancelButtonIndex=0
        alertView.delegate=delegate
        alertView.show()
        
    }
    
    func displayVipBuyMessage(message : String, delegate: UIAlertViewDelegate) {
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButton(withTitle: "购买")
        alertView.addButton(withTitle: "取消")
        alertView.delegate=delegate
        alertView.show()
    }
    
    func displayVipBuyMessage2(message : String, delegate: UIAlertViewDelegate) {
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButton(withTitle: "购买")
        alertView.addButton(withTitle: "返回")
        alertView.delegate=delegate
        alertView.show()
    }


    
    func displayConfirmMessage(message : String, delegate: UIAlertViewDelegate) {
        let alertView = UIAlertView()
        //alertView.title = "系统提示"
        alertView.message = message
        alertView.addButton(withTitle: "确认")
        alertView.addButton(withTitle: "取消")
        alertView.delegate=delegate
        alertView.show()
    }

    
    func hideKeyboardWhenTappedAround() {
        view.addGestureRecognizer(tap)
    }
    
    func cancleHideKeybaordWhenTappedAround() {
        view.removeGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }


}
