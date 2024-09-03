//
//  SignUpView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI
import CommonCrypto

struct SignUpView: View {
    
    @State private var nickname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var errorMessage: String?
    @State private var signUpSuccessful: Bool = false
    
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
        .navigationDestination(isPresented: $signUpSuccessful) {
            LoginView()
        }
    }
    
    private func signUp() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "모든 필드를 입력해주세요."
            return
        }
        
        guard isValidEmail(id: email) else {
            errorMessage = "유효한 이메일 형식이 아닙니다."
            return
        }
        
        guard isValidPassword(pwd: password) else {
            errorMessage = "비밀번호는 대문자, 숫자를 포함하여 8자리 이상이어야 합니다."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            return
        }
        
        
        let newUser = User(nickname: nickname, email: email, password: password)
        
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            print("baseURL 가져오기 실패")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            errorMessage = "유효하지 않은 URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONEncoder().encode(newUser)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "서버로부터 응답이 없습니다."
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.errorMessage = nil
                    self.signUpSuccessful = true
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = String(data: data, encoding: .utf8)
                }
            }
        }.resume()
    }
    
    func isValidEmail(id: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: id)
    }
    
    func isValidPassword(pwd: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9]).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: pwd)
    }
    
    // SHA-256 해싱 함수
    //    func sha256(_ input: String) -> String {
    //        guard let inputData = input.data(using: .utf8) else { return "" }
    //        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    //        inputData.withUnsafeBytes {
    //            _ = CC_SHA256($0.baseAddress, CC_LONG(inputData.count), &hash)
    //        }
    //        return hash.map { String(format: "%02x", $0) }.joined()
    //    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
