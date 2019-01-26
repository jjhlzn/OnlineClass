//
//  IAPManager.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2019/1/24.
//  Copyright © 2019 tbaranes. All rights reserved.
//

import Foundation

class WalletManager {
    
    private let keyValueDao = KeyValueStore()
    
    func deposite(_ value: Double) {
        var balance = getBalance()
        balance += value
        keyValueDao.save(key: KeyValueStore.key_local_wallet, value: "\(balance)")
    }
    
    func withdraw(_ value: Double) {
        var balance = getBalance()
        balance -= value
        keyValueDao.save(key: KeyValueStore.key_local_wallet, value: "\(balance)")
    }
    
    func getBalance() -> Double {
        let value = keyValueDao.get(key: KeyValueStore.key_local_wallet, defaultValue: "0")!
        return Double(value)!
    }
}
