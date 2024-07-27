//
//  ContentView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI
import SwiftJWT
import Security

struct ContentView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("authToken") var authToken: String?
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
        if let token = getKeychainItem(forKey: "authToken") {
            if isTokenExpired(token: token) {
                deleteKeychainItem(forKey: "authToken")
                authToken = nil
                isLoggedIn = false
            } else {
                authToken = token
                isLoggedIn = true
            }
        } else {
            isLoggedIn = false
        }
    }

    func isTokenExpired(token: String) -> Bool {
        do {
            let jwt = try JWT<MyClaims>(jwtString: token)
            return jwt.claims.exp < Date()
        } catch {
            print("JWT parsing error: \(error)")
            return true
        }
    }

    func getKeychainItem(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            print("키체인 항목 가져오기 성공")
            if let data = item as? Data, let value = String(data: data, encoding: .utf8) {
                return value
            }
        } else {
            print("키체인 항목 가져오기 실패: \(status)")
        }
        return nil
    }

    func deleteKeychainItem(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("키체인 항목 삭제 성공")
        } else {
            print("키체인 항목 삭제 실패: \(status)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
