//
//  AlertView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//


import SwiftUI

struct AlertView: View {
    @State private var priceDataList: [PriceData] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    private let alertService = AlertService()

    var body: some View {
        List {
            ForEach(priceDataList, id: \.id) { priceData in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Price: \(priceData.price, specifier: "%.2f")")
                        Text("Date: \(priceData.date, formatter: itemFormatter)")
                    }
                    .foregroundColor(priceData.isTriggered ? .red : .black) // 알림이 울리면 색상 변경

                    Spacer()

                    Button(action: {
                        deleteAlert(priceData: priceData)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("알림 내역")
        .onAppear(perform: loadAlerts)
    }

    private func loadAlerts() {
        alertService.fetchAlerts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let alerts):
                    self.priceDataList = alerts
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func deleteAlert(priceData: PriceData) {
        guard let id = priceData.id else { return }
        alertService.deleteAlert(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = priceDataList.firstIndex(where: { $0.id == id }) {
                        priceDataList.remove(at: index)
                    }
                case .failure(let error):
                    print("Failed to delete alert: \(error.localizedDescription)")
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        offsets.map { priceDataList[$0] }.forEach { deleteAlert(priceData: $0) }
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
