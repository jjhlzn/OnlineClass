//
//  BuyRecordManager.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2019/1/24.
//  Copyright © 2019 tbaranes. All rights reserved.
//

import Foundation
import QorumLogs

class BuyRecordManager {
    let keyValueStore = KeyValueStore()
    let walletManager = WalletManager()
    
    //存储购买商品的票据，并且需要相应的知点减掉
    func buyProduct(productId : String, price: Double, ticket: String) {
        let balance = walletManager.getBalance()
        if balance >= price {
            walletManager.withdraw(price)
            var tickets = getAllTickets()
            tickets = tickets + KeyValueStore.BuyRecordSeparator + ticket
            keyValueStore.save(key: KeyValueStore.key_buy_records, value: tickets)
        }
        
    }
    
    //ticket通过###分隔
    func getAllTickets() -> String {
        let tickets = keyValueStore.get(key: KeyValueStore.key_buy_records, defaultValue: "")!
        QL1(tickets)
        return tickets
    }
    
}
