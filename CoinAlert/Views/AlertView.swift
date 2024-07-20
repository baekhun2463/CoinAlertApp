//
//  AlertView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//

import SwiftUI
import SwiftData

struct AlertView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var priceDataList: [PriceData]

    var body: some View {
        List {
            ForEach(priceDataList) { priceData in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Price: \(priceData.price, specifier: "%.2f")")
                        Text("Date: \(priceData.date, formatter: itemFormatter)")
                    }
                    .foregroundColor(priceData.isTriggered ? .red : .black) // 알림이 울리면 색상 변경

                    Spacer()

                    Button(action: {
                        modelContext.delete(priceData)
                        try? modelContext.save()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("알림 내역")
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { priceDataList[$0] }.forEach(modelContext.delete)
            try? modelContext.save()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()


struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
    }
}
