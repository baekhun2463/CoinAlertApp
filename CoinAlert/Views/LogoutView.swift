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
        // 로그아웃 로직: 토큰 삭제 및 로그인 상태 변경
        authToken = nil
        isLoggedIn = false
    }
}

struct LogoutView_Previews: PreviewProvider {
    static var previews: some View {
        LogoutView()
    }
}

