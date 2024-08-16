import SwiftUI
import SwiftJWT
import AuthenticationServices

@main
struct CoinAlertApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if !isLoggedIn {
                ContentView()
                    .onAppear {
                        checkLoginStatus()
                    }
            } else {
                MainTabView()
                    .onAppear {
                        checkLoginStatus()
                    }
            }
        }
    }

    func checkLoginStatus() {
        if let token = loadJWTFromKeychain(), !isTokenExpired(token: token) {
            isLoggedIn = true
        } else {
            isLoggedIn = false
            // 필요시 키체인에서 토큰 삭제 로직 추가 가능
            deleteJWTFromKeychain()
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

    func deleteJWTFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken"
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("키체인에서 JWT 삭제 성공")
        } else {
            print("키체인에서 JWT 삭제 실패: \(status)")
        }
    }

    func isTokenExpired(token: String) -> Bool {
        do {
            let jwt = try JWT<CustomClaims>(jwtString: token)
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
}

// 구조체 이름을 CustomClaims로 변경하여 중복된 선언 문제를 해결
struct CustomClaims: Claims {
    let sub: String
    let exp: Date?
}
