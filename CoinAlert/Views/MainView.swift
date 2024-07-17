//
//  MainView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI
import UserNotifications

struct MainView: View {
    @State private var bitcoinPrice: PriceData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingAlert = false
    @State private var alertPrice: Double?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .onAppear {
                            fetchBitcoinPrice()
                        }
                } else if let bitcoinPrice = bitcoinPrice {
                    VStack {
                        Text("Bitcoin Price")
                            .font(.largeTitle)
                        Text("$\(bitcoinPrice.price, specifier: "%.0f")")
                            .font(.title)
                            .foregroundColor(.green)
                        // 차트 표시하는 자리
                        
                        // 알림 설정 버튼
                        NavigationLink(destination: SetAlertView(onSave: { price in
                            alertPrice = price
                            scheduleNotification(for: bitcoinPrice, alertPrice: price)
                        })) {
                            Text("알림 설정")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Bitcoin Tracker")
        }
    }
    
    func fetchBitcoinPrice() {
        BitcoinPriceService().fetchBitcoinPrice { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let price):
                    bitcoinPrice = price
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func scheduleNotification(for priceData: PriceData, alertPrice: Double) {
        let content = UNMutableNotificationContent()
        content.title = "비트코인 가격 알림"
        content.body = "설정된 가격 \(String(format: "%.0f", alertPrice))에 도달했습니다. 현재 비트코인 가격은 $\(String(format: "%.0f", priceData.price))입니다."
        content.sound = .default
        
        // 트리거 설정 (예: 5초 후)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // 요청 생성
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // 알림 추가
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 추가 에러: \(error.localizedDescription)")
            } else {
                print("알림이 성공적으로 추가되었습니다.")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

