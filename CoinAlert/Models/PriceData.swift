//
//  PriceData.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//

import Foundation
import SwiftData

@Model
final class PriceData {
    @Attribute(.unique) var id: UUID
    @Attribute var price: Double
    @Attribute var date: Date
    @Attribute var isTriggered: Bool
    @Attribute var alertPrice: Double
    
    @Relationship var user: User?

    init(price: Double, date: Date, isTriggered: Bool = false, alertPrice: Double = 0.0, user: User? = nil) {
        self.id = UUID()
        self.price = price
        self.date = date
        self.isTriggered = isTriggered
        self.alertPrice = alertPrice
        self.user = user
    }
}
