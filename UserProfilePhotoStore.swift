//
//  UserProfilePhotoStore.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/24.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit

class UserProfilePhotoStore : NSObject {
    let imageName = "userimage.png"
    
    func saveOrUpdate(image : UIImage) {
        if let data = UIImagePNGRepresentation(image) {
            let filename = fileInDocumentsDirectory(imageName)
            
            let killFile = NSFileManager.defaultManager()
            if (killFile.isDeletableFileAtPath(filename)){
                do {
                    try killFile.removeItemAtPath(filename)
                }
                catch let error as NSError {
                    error.description
                }
            }
            data.writeToFile(filename, atomically: true)
        }
    }
    
    func delete() {
        let fileManager = NSFileManager.defaultManager()
        let filePath = fileInDocumentsDirectory(imageName)
        do {
            try fileManager.removeItemAtPath(filePath)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    private func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("missing image at: \(path)")
        }
        print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
        
    }
    
    private func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    private func fileInDocumentsDirectory(filename: String) -> String {
        print("fileInDocumentsDirectory()")

        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
        
    }
    
    func get() -> UIImage? {
        print("get()")
        let image = loadImageFromPath(fileInDocumentsDirectory(imageName))
        if image == nil {
            return nil
        }
        return image!
    }
}