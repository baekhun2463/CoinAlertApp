//
//  FindUsernameView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI

//1. 이메일 입력을 받고 유효한 이메일이면 아이디 리턴 else 알맞는 메시지 리턴

struct FindUsernameView: View {
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("아이디 찾기")
                    .font(.largeTitle)
                    .bold()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("이메일")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("이메일을 입력해주세요", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(5)
                }
                
                Button(action: {
                    // 아이디 찾기 액션
            
                }) {
                    Text("아이디 찾기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
}

struct FindUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        FindUsernameView()
    }
}

