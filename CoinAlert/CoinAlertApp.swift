import SwiftUI
import AuthenticationServices

@main
struct CoinAlertApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if !isLoggedIn {
                ContentView()
            } else {
                MainTabView()
            }
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
