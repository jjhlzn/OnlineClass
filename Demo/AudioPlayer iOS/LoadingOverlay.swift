//
//  LoadingOverlay.swift
//  ContractApp
//
//  Created by 刘兆娜 on 16/3/11.
//  Copyright © 2016年 金军航. All rights reserved.
//

import Foundation
import UIKit


public class LoadingOverlay{
    
    var overlayView = UIView()
    //var backgroundView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView!) {
        overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        activityIndicator.layer.cornerRadius = 05;
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.5)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = overlayView.center
        activityIndicator.color = UIColor.white
        overlayView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        view.addSubview(overlayView)
    }

    
    private func makeLabel(msg: String, superView: UIView) -> UILabel {
        let screenWidth = UIScreen.main.bounds.width
        let labelWidth =  screenWidth / 4
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 21))
        
        label.center.x = superView.bounds.width / 2
        label.center.y = superView.bounds.height / 2 + 20 + 5
        
        label.textAlignment = .center
        label.font = label.font.withSize(13)
        label.textColor = UIColor.black
        label.text = msg
        
        return label
        
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}

public class LoadingOverlayWithMessage{
    
    var overlayView = UIView()
    //var backgroundView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: LoadingOverlayWithMessage {
        struct Static {
            static let instance: LoadingOverlayWithMessage = LoadingOverlayWithMessage()
        }
        return Static.instance
    }
    
    
     public func showOverlayWithMessage(msg: String, view: UIView!) {
     
         overlayView = UIView(frame: UIScreen.main.bounds)
         overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
         activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
         activityIndicator.layer.cornerRadius = 05;
         activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.5)
         activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
         activityIndicator.center = overlayView.center
         activityIndicator.color = UIColor.white
         overlayView.addSubview(activityIndicator)
        
         let text = makeLabel(msg: msg, superView: overlayView)
         overlayView.addSubview(text)
        
         activityIndicator.startAnimating()
        
         view.addSubview(overlayView)
     }
    
    private func makeLabel(msg: String, superView: UIView) -> UILabel {
        let screenWidth = UIScreen.main.bounds.width
        let labelWidth =  screenWidth / 4
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 21))
        
        label.center.x = superView.bounds.width / 2
        label.center.y = superView.bounds.height / 2 + 20 + 5
        
        label.textAlignment = .center
        label.font = label.font.withSize(13)
        label.textColor = UIColor.white
        label.text = msg
        
        return label
        
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}

public class LoadingCircle {
    
    var activityIndicator = UIActivityIndicatorView()
    
    public func show(view: UIView!) {

        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        activityIndicator.layer.cornerRadius = 05;
        activityIndicator.backgroundColor = nil
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        activityIndicator.center = view.center
        activityIndicator.color = UIColor.lightGray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
    }
    
    public func hide() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

}
