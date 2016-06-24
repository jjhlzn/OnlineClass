//
//  SetProfilePhotoController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/23.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import ALCameraViewController

class SetProfilePhotoController1: BaseUIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //openLibrary()
        //openCamera()
    }
    
    func openLibrary() {
        let croppingEnabled = true
        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled) { image, asset in
            self.imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(libraryViewController, animated: true, completion: nil)
    }
    
    func openCamera() {
        let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak self] image, asset in
            self?.imageView.image = image
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
    }


    @IBAction func photoSelectPressed(sender: AnyObject) {
        openLibrary()
    }
    
    
    
    @IBAction func cameraPressed(sender: AnyObject) {
        openCamera()
    }

}
