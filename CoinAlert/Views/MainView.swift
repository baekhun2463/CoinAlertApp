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
    @State private var alertPrice: Double?
    @State private var notificationPermissionGranted = false
    @State private var showAlert = false
    @State private var alertMessage = ""

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
                        
                        NavigationLink(destination: SetAlertView(onSave: { price in
                            alertPrice = price
                            if notificationPermissionGranted {
                                scheduleNotification(for: price)
                            } else {
                                requestNotificationPermission()
                            }
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("알림 권한 필요"),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("설정으로 이동")) {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                        }
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
        .onAppear(perform: checkNotificationPermission)
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
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationPermissionGranted = settings.authorizationStatus == .authorized
                if !notificationPermissionGranted {
                    requestNotificationPermission()
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                } else {
                    notificationPermissionGranted = granted
                    if granted {
                        if let price = alertPrice {
                            scheduleNotification(for: price)
                        }
                    } else {
                        alertMessage = "알림을 설정하려면 알림 권한이 필요합니다. 설정에서 권한을 허용해주세요."
                        showAlert = true
                    }
                }
            }
        }
    }
    
    func scheduleNotification(for alertPrice: Double) {
        let content = UNMutableNotificationContent()
        content.title = "비트코인 가격 알림"
        content.body = "설정된 가격 \(String(format: "%.0f", alertPrice))에 도달했습니다."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
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



