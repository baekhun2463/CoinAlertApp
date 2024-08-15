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
                checkLoginStatus()
                showSplashView = false
            }
        }
    }

    func checkLoginStatus() {
        if let token = authToken, !isTokenExpired(token: token) {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }

    func isTokenExpired(token: String) -> Bool {
        do {
            let jwt = try JWT<MyClaims>(jwtString: token)
            let expirationDate = jwt.claims.exp
            return Date() > expirationDate
        } catch {
            print("JWT 파싱 오류: \(error)")
            return true
        }
    }
}

struct MyClaims: Claims {
    let sub: String
    let exp: Date
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
