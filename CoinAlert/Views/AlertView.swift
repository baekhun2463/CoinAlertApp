//
//  AlertView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//

import SwiftUI
import SwiftData

struct AlertView: View {

    @Query var priceDataList: [PriceData]

    var body: some View {
        ForEach(priceDataList){ priceData in
            Text("\(priceData.date, format: Date.FormatStyle(date: .numeric, time: .standard))")
            Text("\(priceData.price)")
        }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
    }
}
