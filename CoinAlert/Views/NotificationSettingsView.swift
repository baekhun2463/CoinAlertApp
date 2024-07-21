//
//  NotificationSettingsView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @State private var notificationsEnabled: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            Text("알림 설정")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            Toggle(isOn: $notificationsEnabled) {
                Text("알림 활성화")
                    .font(.headline)
            }
            .padding()
            .onChange(of: notificationsEnabled) { value in
                updateNotificationSettings(enabled: value)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            checkNotificationSettings()
        }
    }

    func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    func updateNotificationSettings(enabled: Bool) {
        if enabled {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        notificationsEnabled = granted
                    }
                }
            }
        } else {
            // 알림 비활성화 로직 (필요시 추가 구현)
            notificationsEnabled = false
        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
