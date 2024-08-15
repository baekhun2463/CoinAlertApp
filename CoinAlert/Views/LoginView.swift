import SwiftUI
import Security
import Combine

struct LoginView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var loginFailed: Bool = false
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("로그인")
                    .font(.largeTitle)
                    .bold()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("아이디")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("아이디를 입력해주세요", text: $email)
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
                
                if loginFailed {
                    Text("로그인 실패. 아이디와 비밀번호를 확인해주세요.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom)
                }
                
                if isLoading {
                    ProgressView()
                        .padding(.top)
                } else {
                    Button(action: {
                        login()
                    }) {
                        Text("로그인")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }

                HStack {
                    Spacer()
                    NavigationLink(destination: FindUsernameView()) {
                        Text("아이디 찾기")
                            .foregroundColor(.gray)
                    }
                    Text(" | ")
                        .foregroundColor(.gray)
                    NavigationLink(destination: ResetPasswordView()) {
                        Text("비밀번호 재설정")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical)
                
                HStack {
                    Text("계정이 없으신가요?")
                        .foregroundColor(.gray)
                    NavigationLink(destination: SignUpView()) {
                        Text("회원가입")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom)
            }
            .padding()
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            MainTabView()
        }
    }

    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            loginFailed = true
            return
        }

        isLoading = true

        let loginService = LoginService()
        let loginModel = LoginModel(email: email, password: password)
        
        loginService.validateLoginDetails(user: loginModel) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    saveJWTToKeychain(token: response.jwt)
                    self.isLoggedIn = true
                    self.loginFailed = false
                case .failure(let error):
                    self.loginFailed = true
                    print("Login failed with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // JWT를 키체인에 저장하는 함수
    func saveJWTToKeychain(token: String) {
        let tokenData = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // 기존 항목이 있는 경우 삭제
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("JWT 저장 성공")
        } else {
            print("JWT 저장 실패: \(status)")
        }
    }
}

struct LoginResponse: Codable {
    let jwt: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
