//
//  ResetPasswordView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI
import SwiftData

struct ResetPasswordView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var resetFailed: Bool = false
    @State private var resetSuccess: Bool = false
    @State private var navigateToLogin: Bool = false
    
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("비밀번호 재설정")
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
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("비밀번호")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        if showPassword {
                            TextField("비밀번호를 입력해주세요", text: $password)
                        } else {
                            SecureField("비밀번호를 입력해주세요", text: $password)
                        }
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye" : "eye.slash")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("비밀번호 확인")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        if showPassword {
                            TextField("비밀번호를 다시 입력해주세요", text: $confirmPassword)
                        } else {
                            SecureField("비밀번호를 다시 입력해주세요", text: $confirmPassword)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                }
                
                if resetFailed {
                    Text("비밀번호 재설정 실패. 이메일을 확인해주세요.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom)
                }
                
                if resetSuccess {
                    Text("비밀번호 재설정 성공.")
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.bottom)
                }
                
                Button(action: {
                    resetPassword()
                }) {
                    Text("비밀번호 재설정")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                .navigationDestination(isPresented: $navigateToLogin) {
                    LoginView()
                }
                Spacer()
            }
            .padding()
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
    
    func resetPassword() {
        guard !email.isEmpty, !password.isEmpty, password == confirmPassword else {
            resetFailed = true
            return
        }
        
        let predicate = #Predicate<User> { $0.email == email }
        let fetchDescriptor = FetchDescriptor<User>(predicate: predicate)
        
        do {
            let users = try modelContext.fetch(fetchDescriptor)
            if let user = users.first {
                user.password = password
                try modelContext.save()
                resetFailed = false
                resetSuccess = true
                navigateToLogin = true
            } else {
                resetFailed = true
            }
        } catch {
            print("비밀번호 재설정 에러: \(error)")
            resetFailed = true
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
