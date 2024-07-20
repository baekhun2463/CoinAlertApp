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
    
    init(price: Double, date: Date) {
        self.id = UUID()
        self.price = price
        self.date = date
    }
}
