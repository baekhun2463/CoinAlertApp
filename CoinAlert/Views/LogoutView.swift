//
//  LogoutView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI

struct LogoutView: View {

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
                // 로그아웃 액션
                @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
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
}

struct LogoutView_Previews: PreviewProvider {
    static var previews: some View {
        LogoutView()
    }
}

