//
//  ContentView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI
import SwiftJWT
import Security
import AuthenticationServices

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
                //                checkLoginStatus()
                showSplashView = false
            }
        }
    }
    
    //    func checkLoginStatus() {
    //        if let token = getKeychainItem(forKey: "authToken") {
    ////            if isTokenExpired(token: token) {
    ////                deleteKeychainItem(forKey: "authToken")
    ////                authToken = nil
    ////                isLoggedIn = false
    ////            } else {
    ////                // 토큰 연장 로직 추가
    ////                if let newToken = refreshToken(token: token) {
    ////                    saveKeychainItem(newToken, forKey: "authToken")
    ////                    authToken = newToken
    ////                }
    //                authToken = token
    //                isLoggedIn = true
    //            }
    //        } else {
    //            isLoggedIn = false
    //        }
    //    }
    
    //    func isTokenExpired(token: String) -> Bool {
    //        do {
    //            let jwt = try JWT<MyClaims>(jwtString: token)
    //            return jwt.claims.exp < Date()
    //        } catch {
    //            print("JWT parsing error: \(error)")
    //            return true
    //        }
    //    }
    //
    //    func refreshToken(token: String) -> String? {
    //        do {
    //            let jwt = try JWT<MyClaims>(jwtString: token)
    //            let newExpirationDate = Date(timeIntervalSinceNow: 7200) // 2시간 연장
    //            let claims = MyClaims(sub: jwt.claims.sub, email: jwt.claims.email, exp: newExpirationDate)
    //            var newJWT = JWT(claims: claims)
    //
    //            guard let key = getSecretKey() else {
    //                print("비밀 키를 가져올 수 없습니다.")
    //                return nil
    //            }
    //
    //            let signer = JWTSigner.hs256(key: Data(key.utf8))
    //
    //            do {
    //                let signedJWT = try newJWT.sign(using: signer)
    //                return signedJWT
    //            } catch {
    //                print("JWT 생성 에러: \(error)")
    //                return nil
    //            }
    //        } catch {
    //            print("JWT parsing error: \(error)")
    //            return nil
    //        }
    //    }
    //
    //    func getSecretKey() -> String? {
    //        return getKeychainItem(forKey: "SECRET_KEY")
    //    }
    //
    //    func getKeychainItem(forKey key: String) -> String? {
    //        let query: [String: Any] = [
    //            kSecClass as String: kSecClassGenericPassword,
    //            kSecAttrAccount as String: key,
    //            kSecReturnData as String: true,
    //            kSecMatchLimit as String: kSecMatchLimitOne
    //        ]
    //
    //        var item: CFTypeRef?
    //        let status = SecItemCopyMatching(query as CFDictionary, &item)
    //
    //        if status == errSecSuccess {
    //            print("키체인 항목 가져오기 성공")
    //            if let data = item as? Data, let value = String(data: data, encoding: .utf8) {
    //                return value
    //            }
    //        } else {
    //            print("키체인 항목 가져오기 실패: \(status)")
    //        }
    //        return nil
    //    }
    //
    //    func deleteKeychainItem(forKey key: String) {
    //        let query: [String: Any] = [
    //            kSecClass as String: kSecClassGenericPassword,
    //            kSecAttrAccount as String: key
    //        ]
    //        let status = SecItemDelete(query as CFDictionary)
    //        if status == errSecSuccess {
    //            print("키체인 항목 삭제 성공")
    //        } else {
    //            print("키체인 항목 삭제 실패: \(status)")
    //        }
    //    }
    //
    //    func saveKeychainItem(_ value: String, forKey key: String) -> Bool {
    //        guard let data = value.data(using: .utf8) else { return false }
    //
    //        let query: [String: Any] = [
    //            kSecClass as String: kSecClassGenericPassword,
    //            kSecAttrAccount as String: key,
    //            kSecValueData as String: data,
    //            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    //        ]
    //
    //        // 기존 항목이 있는 경우 삭제
    //        SecItemDelete(query as CFDictionary)
    //
    //        let status = SecItemAdd(query as CFDictionary, nil)
    //        if status == errSecSuccess {
    //            print("키체인 항목 저장 성공")
    //        } else {
    //            print("키체인 항목 저장 실패: \(status)")
    //        }
    //        return status == errSecSuccess
    //    }
    //}
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
