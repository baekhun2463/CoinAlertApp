//
//  PriceData.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//

import Foundation

struct PriceData: Codable {
    var id: Int64?
    var price: Double
    var date: Date
    var isTriggered: Bool
    var alertPrice: Double

    init(price: Double, date: Date, isTriggered: Bool = false, alertPrice: Double = 0.0) {
        self.price = price
        self.date = date
        self.isTriggered = isTriggered
        self.alertPrice = alertPrice
    }
}
