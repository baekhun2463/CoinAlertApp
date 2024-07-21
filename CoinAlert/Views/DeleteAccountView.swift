//
//  DeleteAccountView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI

struct DeleteAccountView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("계정 탈퇴")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            Text("계정을 탈퇴하면 복구할 수 없습니다. 정말로 탈퇴하시겠습니까?")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                // 탈퇴 액션
            }) {
                Text("계정 탈퇴")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView()
    }
}

