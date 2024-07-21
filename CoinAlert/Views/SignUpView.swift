//
//  SignUpView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI
import SwiftData

//1. 아이디 유효성 검사 및 중복 검사
//2. 비밀번호 유효성 검사
//3. 비밀번호와 비밀번호 확인이 같은 지 확인 로직
//4. 회원가입 로직

struct SignUpView: View {
    @Environment(\.modelContext) var modelContext: ModelContext
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    
    @State private var nickname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("회원가입")
                    .font(.largeTitle)
                    .bold()
                

                VStack(alignment: .leading, spacing: 10) {
                    Text("닉네임")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("닉네임을 입력해주세요", text: $nickname)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(5)
                }
                
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
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    signUp()
                }) {
                    Text("회원가입")
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
    
    private func signUp() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else{
            errorMessage = "입력해주세요."
            return
        }
        
        guard !isValidEmail(id: email) else {
            errorMessage = "이메일 형식이 아닙니다."
            return
        }
        
        guard !isValidPassword(pwd: password) else {
            errorMessage = "대문자, 숫자를 포함해서 8자리 이상이어야 합니다."
            return
        }
        
        guard  password == confirmPassword else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            return
        }
        
        let newUser = User(email: email, password: password)
        modelContext.insert(newUser)
        
        do {
            try modelContext.save()
            errorMessage = "회원가입 성공"
            isLoggedIn = true
        }catch {
            errorMessage = "회원가입 실패: \(error.localizedDescription)"
        }
    }
    
    // 이메일 형식 검사
    // @ 앞에 알파벳, 숫자, 특수문자가 포함될 수 있고 @ 뒤에는 알파벳, 숫자, 그리고 . 뒤에는 알파벳 2자리 이상
    func isValidEmail(id: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: id)
    }
    
    // 비밀번호 형식 검사
    //소문자, 대문자, 숫자 8자리 이상
    func isValidPassword(pwd: String) -> Bool {
        let passwordRegEx = "^[a-zA-Z0-9]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: pwd)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .modelContainer(for: User.self, inMemory: true)
    }
}

