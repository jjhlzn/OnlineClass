//
//  UserProfilePhotoStore.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/24.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import UIKit
import QorumLogs

class ImageStore : NSObject {
    var imageName : String {
        get {
            return ""
        }
    }
    
    func saveOrUpdate(image : UIImage) {
        
        if let data = UIImagePNGRepresentation(image) {
            print("imageName = \(imageName)")
            let filename = fileInDocumentsDirectory(filename: imageName)
            
            let killFile = FileManager.default
            if (killFile.isDeletableFile(atPath: filename)){
                do {
                    try killFile.removeItem(atPath: filename)
                }
                catch let error as NSError {
                    QL4(error)
                }
            }
            do {
                try data.write(to: URL(string: filename)!, options: .atomic)
            } catch let error as NSError {
                QL4(error)
            }
        }
    }
    
    func delete() {
        
        let fileManager = FileManager.default
        let filePath = fileInDocumentsDirectory(filename: imageName)
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
            QL4(error)
        }
    }
    
    private func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            //print("missing image at: \(path)")
        }
        //print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
        
    }
    
    
    private func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    private func fileInDocumentsDirectory(filename: String) -> String {
        //print("fileInDocumentsDirectory()")
        
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
        
    }
    
    func get() -> UIImage? {
        //return nil
        
        //print("get()")
        let image = loadImageFromPath(path: fileInDocumentsDirectory(filename: imageName))
        if image == nil {
            return nil
        }
        return image!
    }
}
