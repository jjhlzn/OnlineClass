//
//  ExtendFunctionImageStore.swift
//  jufangzhushou
//
//  Created by 金军航 on 17/5/23.
//  Copyright © 2017年 tbaranes. All rights reserved.
//

import Foundation
import UIKit

class ExtendFunctionImageStore : NSObject {

    private func makeImageName(imageUrl: String) -> String {
        return md5(string: imageUrl)
    }
    
    private func md5(string string: String) -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    func saveOrUpdate(imageUrl: String, image : UIImage) {
        if let data = UIImagePNGRepresentation(image) {
            print("imageName = \(makeImageName(imageUrl))")
            let filename = fileInDocumentsDirectory(makeImageName(imageUrl))
            
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
    
    func getImage(imageUrl: String) -> UIImage? {
        let image = loadImageFromPath(fileInDocumentsDirectory(makeImageName(imageUrl)))
        if image == nil {
            return nil
        }
        return image!
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
    
    
}