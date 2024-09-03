//
//  LogoutView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI

struct LogoutView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("authToken") var authToken: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("로그아웃")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            Text("정말로 로그아웃 하시겠습니까?")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                logout()
            }) {
                Text("로그아웃")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
    
    func logout() {
        // JWT를 키체인에서 삭제하는 로직
        deleteJWTFromKeychain()
    }
    
    func deleteJWTFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            authToken = nil
            isLoggedIn = false
            print("JWT 삭제 성공")
            
        } else {
            print("JWT 삭제 실패: \(status)")
        }
    }
}

struct LogoutView_Previews: PreviewProvider {
    static var previews: some View {
        LogoutView()
    }
}

