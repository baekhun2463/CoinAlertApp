import SwiftUI

struct ResetPasswordView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var resetFailed: Bool = false
    @State private var resetSuccess: Bool = false
    @State private var navigateToLogin: Bool = false

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
        
        let resetDetails = ["email": email, "password": password]
        
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            print("baseURL 가져오기 실패")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/auth/reset-password") else {
            print("유효하지 않은 URL")
            self.resetFailed = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: resetDetails)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.resetFailed = true
                    print("비밀번호 재설정 에러: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.resetFailed = true
                    print("서버로부터 응답이 없습니다.")
                }
                return
            }

            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.resetFailed = false
                    self.resetSuccess = true
                    self.navigateToLogin = true
                }
            } else {
                DispatchQueue.main.async {
                    self.resetFailed = true
                    print("비밀번호 재설정 실패: 서버 응답 코드 \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
