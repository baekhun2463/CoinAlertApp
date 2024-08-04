import SwiftUI
import Security
import Combine

struct LoginView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("authToken") var authToken: String?

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
    }
    
    // 로그인 함수
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            loginFailed = true
            return
        }

        isLoading = true

        guard let url = URL(string: "http://localhost:8080/auth/login") else {
            print("유효하지 않은 URL")
            self.isLoading = false
            self.loginFailed = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginDetails = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: loginDetails)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.loginFailed = true
                    print("로그인 에러: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.loginFailed = true
                    print("서버로부터 응답이 없습니다.")
                }
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    DispatchQueue.main.async {
                        self.authToken = user.token
                        self.saveKeychainItem(user.token, forKey: "authToken")
                        self.isLoggedIn = true
                        self.loginFailed = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.loginFailed = true
                        print("응답 데이터 파싱 에러: \(error.localizedDescription)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.loginFailed = true
                    print("로그인 실패: 서버 응답 코드 \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }


    // 키체인 항목 저장
    func saveKeychainItem(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // 기존 항목이 있는 경우 삭제
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("키체인 항목 저장 성공")
        } else {
            print("키체인 항목 저장 실패: \(status)")
        }
        return status == errSecSuccess
    }

    // 키체인 항목 가져오기
    func getKeychainItem(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            print("키체인 항목 가져오기 성공")
            if let data = item as? Data, let value = String(data: data, encoding: .utf8) {
                return value
            }
        } else {
            print("키체인 항목 가져오기 실패: \(status)")
        }
        return nil
    }
}

struct LoginResponse: Codable {
    let token: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
