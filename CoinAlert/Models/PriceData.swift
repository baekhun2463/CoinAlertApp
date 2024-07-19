//
//  PriceData.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//


import Foundation

struct PriceData: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}
