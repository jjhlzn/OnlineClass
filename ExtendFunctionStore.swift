//
//  ExtendFunctionMessageManager.swift
//  jufangzhushou
//
//  Created by 金军航 on 17/1/9.
//  Copyright © 2017年 tbaranes. All rights reserved.
//

import Foundation
import QorumLogs

class ExtendFunctionStore {
    static let instance:ExtendFunctionStore = ExtendFunctionStore()
    
    
    let keyValueDao = KeyValueStore()
    var map = [String: Int]()
    var isShowMap = [String: Bool]()
    
    private init() {
        load()
    }
    
    private func load() {
        self.map = [String: Int]()
        self.isShowMap = [String: Bool]()
        let functions = ExtendFunctionMananger.getAllFunctions()
        functions.forEach() {
            function in
            map[function.code] = Int(keyValueDao.get(key: getHasMessageKey(code: function.code), defaultValue: "0")!)
            isShowMap[function.code] = Int(keyValueDao.get(key: getIsShowKey(code: function.code), defaultValue: function.isShowDefault ? "1" : "0")!)! > 0
            
            
        }
        QL1(isShowMap)
    }
    
    private func getHasMessageKey(code: String) -> String {
        return "\(code)_message_count"
    }
    
    private func getIsShowKey(code: String) -> String {
        return "\(code)_is_show"
    }
    
    private func getNameKey(code: String) -> String {
        return "\(code)_name"
    }
    
    private func getImageUrlKey(code: String) -> String {
        return "\(code)_imageUrl"
    }
    
    func hasMessage(code: String) -> Bool {
        //QL1("code: \(code), hasMessage: \(map[code]!)")
        if let value = map[code] {
            return 0 != Int(value)
        }
        return false
    }
    
    func updateMessageCount(code: String, value: Int) {
        keyValueDao.save(key: getHasMessageKey(code: code), value: "\(value)")
        map[code] = value
    }
    
    func clearMessage(code: String, value: Int) {
        updateMessageCount(code: code, value: 0)
    }
    
    func isShow(code: String, defaultValue: Bool) -> Bool {
        //QL1("code: \(code), isShow: \(isShowMap[code])")
        if let value = isShowMap[code] {
            return value
        }
        return defaultValue
    }
    
    func updateShow(code: String, value: Bool) {
        keyValueDao.save(key: getIsShowKey(code: code), value: "\(value ? "1" : "0")")
        isShowMap[code] = value

    }
    
    func updateFunctionName(code: String, value: String) {
        keyValueDao.save(key: getNameKey(code: code), value: value)
    }
    
    func getFunctionName(code: String, defaultValue: String) -> String {
        return keyValueDao.get(key: getNameKey(code: code), defaultValue: defaultValue)!
    }
    
    func updateImageUrl(code: String, value: String) {
        keyValueDao.save(key: getImageUrlKey(code: code), value: value)
    }
    
    func getImageUrl(code: String) -> String{
        return keyValueDao.get(key: getImageUrlKey(code: code), defaultValue: "")!
    }
}
