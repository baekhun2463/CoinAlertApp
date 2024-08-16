import SwiftUI
import SwiftJWT
import Security

struct ContentView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var showSplashView = true

    var body: some View {
        Group {
            if showSplashView {
                SplashView()
                    .onAppear {
                        loadData()
                    }
            } else {
                if !isLoggedIn {
                    LoginView()
                } else {
                    MainTabView()
                }
            }
        }
    }

    func loadData() {
        DispatchQueue.global().async {
            sleep(1)
            DispatchQueue.main.async {
                checkLoginStatus()
                showSplashView = false
            }
        }
    }

    func checkLoginStatus() {
        if let token = loadJWTFromKeychain(), !isTokenExpired(token: token) {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }

    func isTokenExpired(token: String) -> Bool {
        do {
            let jwt = try JWT<MyClaims>(jwtString: token)
            if let expirationDate = jwt.claims.exp {
                return Date() > expirationDate
            } else {
                print("만료 시간 없음")
                return true
            }
        } catch {
            print("JWT 파싱 오류: \(error)")
            return true
        }
    }

    func loadJWTFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            if let data = item as? Data, let token = String(data: data, encoding: .utf8) {
                return token
            }
        } else {
            print("키체인에서 JWT를 가져오지 못함: \(status)")
        }
        return nil
    }
}

struct MyClaims: Claims {
    let sub: String
    let exp: Date?
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
