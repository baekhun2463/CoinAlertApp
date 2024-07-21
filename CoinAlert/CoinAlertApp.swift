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
            PriceData.self,
            User.self,
            Post.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
 
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
