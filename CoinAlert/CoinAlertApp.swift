//
//  CoinAlertApp.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI
import SwiftData

@main
struct CoinAlertApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PriceData.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

//        // Remove existing persistent store file if exists
//        removePersistentStore()
//        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(sharedModelContainer)
        }
    }
}

//func removePersistentStore() {
//    let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("default.store")
//
//    if let storeURL = storeURL {
//        do {
//            try FileManager.default.removeItem(at: storeURL)
//            print("Persistent store deleted.")
//        } catch {
//            print("Failed to delete persistent store: \(error)")
//        }
//    }
//}
