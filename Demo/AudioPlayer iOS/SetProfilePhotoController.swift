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
import QorumLogs
import Kingfisher

class SetProfilePhotoController: BaseUIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var loading = LoadingOverlayWithMessage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageView.image = UserProfilePhotoStore().get()
        let loginUser = (LoginUserStore().getLoginUser())!
        let url = ServiceConfiguration.GET_PROFILE_IMAGE + "?userid=" + loginUser.userName!
        
        QL1(url)
        
        imageView.kf.setImage(with: ImageResource(downloadURL: URL(string: url)!, cacheKey: ImageCacheKeys.User_Profile_Image))
        
        setLeftBackButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        (self.navigationController?.viewControllers[0] as! MyInfoVieController).tableView.reloadData()
    }
    
    @IBAction func morePressed(_ sender: Any) {
        presentSettingsActionSheet()
    }
    
    
    private func presentSettingsActionSheet() {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertControllerStyle.actionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:"拍照", style:UIAlertActionStyle.default, handler:{ action in
            self.openCamera()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"从相册中获取", style:UIAlertActionStyle.default, handler:{ action in
            self.openLibrary()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"取消", style:UIAlertActionStyle.cancel, handler:nil))
        present(settingsActionSheet, animated:true, completion:nil)
    }
    
    func openLibrary() {
        let croppingParams = CroppingParameters(isEnabled: true)
        
        let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: croppingParams) { image, asset in
            if image != nil {
                self.imageView.image = image
                self.uploadImage(imageData: UIImageJPEGRepresentation(image!, 1)!)

            }
            self.dismiss(animated: true, completion: nil)
        }
        
        present(libraryViewController, animated: true, completion: nil)
    }
    
    func openCamera() {
        
        let croppingParams = CroppingParameters(isEnabled: true)
        
        let cameraViewController = CameraViewController(croppingParameters: croppingParams) { [weak self] image, asset in
            if image != nil {
                self!.imageView.image = image
                self?.uploadImage(imageData: UIImageJPEGRepresentation(image!, 1)!)

            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    
    private func uploadImage(imageData: Data) {
        
        //TODO:
        
        let loginUser = LoginUserStore().getLoginUser()!
        loading.showOverlayWithMessage(msg: "正在上传头像", view: view)
       
        Alamofire.upload(
            //.POST,
            multipartFormData: { multipartFormData in
    
                multipartFormData.append(imageData, withName: "userimage", fileName: "userimage", mimeType: "image/png")
    
                multipartFormData.append("\(loginUser.userName!)".data(using: String.Encoding.utf8)!, withName: "userid")
                multipartFormData.append("\(loginUser.token!)".data(using: String.Encoding.utf8)!, withName: "token")
                
            },
            to: ServiceConfiguration.UPLOAD_PROFILE_IMAGE,
            
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { (JSON) in

                        QL1("success")
                        //UserProfilePhotoStore().saveOrUpdate(image: UIImage(data: imageData)!)
                    
                        ImageCache.default.store(Image(data: imageData)!, forKey: ImageCacheKeys.User_Profile_Image)
                        let userId = LoginUserStore().getLoginUser()!.userName!
                        ImageCache.default.store(Image(data: imageData)!, forKey: "headimage_"+userId)
                    
                        self.loading.hideOverlayView()
                        ToastMessage.showMessage(view: self.view, message: "头像上传成功")
                        
                    }
                    
                case .failure(let encodingError):
                    //Show Alert in UI
                    print("failure")
                    self.loading.hideOverlayView()
                    ToastMessage.showMessage(view: self.view, message: "头像上传失败")
                }
            }
        );
    }
    
    

}
