//
//  CoinAlertApp.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI
import SwiftData
import AuthenticationServices


@main
struct CoinAlertApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var sharedModelContainer: ModelContainer? {
        return createModelContainer()
    }
    
    var body: some Scene {
            WindowGroup {
                if let modelContainer = sharedModelContainer {
                    if !isLoggedIn {
                        ContentView()
                            .modelContainer(modelContainer)
                    } else {
                        MainTabView()
                            .modelContainer(modelContainer)
                    }
                } else {
                    ErrorView(message: "모델 컨테이너를 생성할 수 없습니다. 앱을 다시 시작해 주세요.")
                }
            }
        }
    
    func createModelContainer() -> ModelContainer? {
        let schema = Schema([
            PriceData.self,
            User.self,
            Post.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Could not create ModelContainer: \(error)")
            return nil
        }
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Text("오류")
                .font(.largeTitle)
                .bold()
            Text(message)
                .padding()
            Button(action: {
                // 앱을 다시 시작하는 로직 또는 다른 대체 로직 추가
            }) {
                Text("재시도")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
