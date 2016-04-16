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
        overlayView = UIView(frame: UIScreen.mainScreen().bounds)
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
        activityIndicator.layer.cornerRadius = 05;
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.6)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.center = overlayView.center
        activityIndicator.color = UIColor(red: 0.6, green: 0.8, blue: 1, alpha: 1)
        overlayView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        view.addSubview(overlayView)
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        //backgroundView.removeFromSuperview()
        overlayView.removeFromSuperview()
    }
}