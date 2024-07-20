//
//  PriceData.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//


import Foundation
import SwiftData

@Model
class PriceData {
    @Attribute(.unique) var id = UUID()
    var price: Double
    var date: Date
    
    init(price: Double, date: Date) {
        self.price = price
        self.date = date
    }
}
