//
//  AppDelegate.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 알림 권한 요청
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("알림 권한 요청 에러: \(error.localizedDescription)")
            }
        }
        return true
    }
}

