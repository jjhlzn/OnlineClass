//
//  ExtendFunctionMessageManager.swift
//  jufangzhushou
//
//  Created by 金军航 on 17/1/9.
//  Copyright © 2017年 tbaranes. All rights reserved.
//

import Foundation

class ExtendFunctionMessageManager {
    static let instance:ExtendFunctionMessageManager = ExtendFunctionMessageManager()
    
    let keyValueDao = KeyValueStore()
    var map = [String: Int]()
    
    private func load() {
        self.map = [String: Int]()
        let functions = ExtendFunctionMananger().getAllFunctions()
        functions.forEach() {
            function in
            map[function.code] = Int(keyValueDao.get(function.code, defaultValue: "0")!)
        }
    }
    
    
    func hasMessage(code: String) -> Bool {
        if let value = map[code] {
            return 0 != Int(value)
        }
        return false
    }
    
    func update(code: String, value: Int) {
        keyValueDao.save(code, value: "\(value)")
        map[code] = value
    }
    
    func clearMessage(code: String, value: Int) {
        update(code, value: 0)
    }
}