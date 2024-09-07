//
//  AlertView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//


import SwiftUI

struct AlertView: View {
    @State private var alertDataList: [AlertData] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    private let alertService = AlertService()

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                List {
                    ForEach(alertDataList, id: \.id) { alertData in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("알람 가격 : \(alertData.alertPrice, specifier: "%.2f")")
                                
                                // 문자열로 받은 날짜를 Date로 변환한 후, 표시 형식으로 변환하여 보여줍니다.
                                if let date = iso8601DateFormatter.date(from: alertData.date) {
                                    Text("날짜 : \(displayFormatter.string(from: date))")
                                } else {
                                    Text("Invalid Date")
                                }
                            }
                            .foregroundColor(alertData.isTriggered ? .red : .black)

                            Spacer()

                            Button(action: {
                                deleteAlert(alertData: alertData)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .navigationTitle("알림 내역")
        .onAppear(perform: loadAlerts)
    }

    private func loadAlerts() {
        alertService.fetchAlerts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let alerts):
                    self.alertDataList = alerts.map { priceData in
                        AlertData(
                            id: priceData.id,
                            date: priceData.date,  // 서버에서 받은 날짜를 그대로 사용
                            isTriggered: priceData.isTriggered,
                            alertPrice: priceData.alertPrice
                        )
                    }
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func deleteAlert(alertData: AlertData) {
        let id = alertData.id
        alertService.deleteAlert(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = alertDataList.firstIndex(where: { $0.id == id }) {
                        alertDataList.remove(at: index)
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to delete alert: \(error.localizedDescription)"
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        offsets.map { alertDataList[$0] }.forEach { deleteAlert(alertData: $0) }
    }
}

// 서버에서 오는 ISO-8601 형식의 날짜를 변환하기 위한 DateFormatter
private let iso8601DateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC 시간대 설정
    return formatter
}()

// 표시할 때 사용할 DateFormatter
private let displayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd hh:mm a" // 원하는 형식으로 설정
    formatter.locale = Locale(identifier: "en_US_POSIX") // AM/PM 형식 유지를 위해 locale 설정
    return formatter
}()

// 서버로부터 수신한 데이터만 포함하는 모델
struct AlertData: Codable {
    var id: Int64
    var date: String // 서버에서 오는 날짜 형식에 맞춰 String으로 정의
    var isTriggered: Bool
    var alertPrice: Double

    // JSON 필드와 Swift 필드 간 매핑
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case isTriggered
        case alertPrice
    }
}
