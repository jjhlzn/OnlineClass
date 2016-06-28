//
//  SetProfilePhotoController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/23.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import ALCameraViewController
import Alamofire

class SetProfilePhotoController: BaseUIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var loading = LoadingOverlayWithMessage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = UserProfilePhotoStore().get()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        (self.navigationController?.viewControllers[0] as! MyInfoVieController).tableView.reloadData()
    }
    
    @IBAction func morePressed(sender: AnyObject) {
        presentSettingsActionSheet()
    }
    
    @IBAction func moreActionPressed(sender: UIButton) {
        presentSettingsActionSheet()
    }
    
    private func presentSettingsActionSheet() {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:"拍照", style:UIAlertActionStyle.Default, handler:{ action in
            self.openCamera()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"从相册中获取", style:UIAlertActionStyle.Default, handler:{ action in
            self.openLibrary()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"取消", style:UIAlertActionStyle.Cancel, handler:nil))
        presentViewController(settingsActionSheet, animated:true, completion:nil)
    }
    
    func openLibrary() {
        let croppingEnabled = true
        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled) { image, asset in
            if image != nil {
                self.imageView.image = image
                self.uploadImage(UIImageJPEGRepresentation(image!, 1)!)

            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(libraryViewController, animated: true, completion: nil)
    }
    
    func openCamera() {
        let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak self] image, asset in
            if image != nil {
                self!.imageView.image = image
                self!.uploadImage(UIImageJPEGRepresentation(image!, 1)!)

            }
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    
    private func uploadImage(imageData: NSData) {
        let loginUser = LoginUserStore().getLoginUser()!
        loading.showOverlayWithMessage("正在上传头像", view: view)
        Alamofire.upload(
            .POST,
            ServiceConfiguration.UPLOAD_PROFILE_IMAGE,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: imageData, name: "userimage", fileName: "userimage", mimeType: "image/png")
                multipartFormData.appendBodyPart(data: loginUser.userName!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"userid")
                multipartFormData.appendBodyPart(data: loginUser.token!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"token")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        //print("Uploading Avatar \(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                        dispatch_async(dispatch_get_main_queue(),{
                            /**
                             *  Update UI Thread about the progress
                             */
                        })
                    }
                    upload.responseJSON { (JSON) in
                        dispatch_async(dispatch_get_main_queue(),{
                            //Show Alert in UI
                            print("success")
                            UserProfilePhotoStore().saveOrUpdate(UIImage(data: imageData)!)
                            self.loading.hideOverlayView()
                            ToastMessage.showMessage(self.view, message: "头像上传成功")
                        })
                    }
                    
                case .Failure(let encodingError):
                    //Show Alert in UI
                    print("failure")
                    self.loading.hideOverlayView()
                    ToastMessage.showMessage(self.view, message: "头像上传失败")
                }
            }
        );
    }
    
    

}
