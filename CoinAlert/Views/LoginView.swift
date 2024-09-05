import SwiftUI
import Security
import Combine
import AuthenticationServices

class LoginViewCoordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}

struct LoginView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var loginFailed: Bool = false
    @State private var isLoading: Bool = false
    @State private var coordinator = LoginViewCoordinator()
    
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
                    
                    Button(action: {
                        startGitHubLogin()
                    }) {
                        HStack {
                            Image("github-mark-white") // 여기에 GitHub 아이콘을 지정합니다.
                                .resizable()
                                .frame(width: 20, height: 20) // 아이콘 크기 조정
                            Text("GitHub로 로그인")
                                .font(.system(size: 16, weight: .semibold)) // 폰트 크기 및 굵기 설정
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
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
    
    func startGitHubLogin() {
        // Info.plist에서 client_id와 customScheme 가져오기
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "GitHubClientID") as? String,
              let customScheme = Bundle.main.object(forInfoDictionaryKey: "CustomScheme") as? String else {
            print("필요한 정보가 없습니다.")
            return
        }
        
        let authURLString = "https://github.com/login/oauth/authorize?client_id=\(clientId)&redirect_uri=\(customScheme)://oauth-callback&scope=user user:email"
        
        guard let authURL = URL(string: authURLString) else {
            print("잘못된 URL입니다.")
            return
        }
        
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: customScheme) { callbackURL, error in
            if let callbackURL = callbackURL, error == nil {
                self.handleGitHubLoginSuccess(callbackURL: callbackURL)
            } else {
                print("GitHub 로그인 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
            }
        }
        session.presentationContextProvider = coordinator
        session.start()
    }
    
    func handleGitHubLoginSuccess(callbackURL: URL) {
        if let code = extractCode(from: callbackURL) {
            exchangeCodeForToken(code: code)
        }
    }
    
    func extractCode(from url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first { $0.name == "code" }?.value
    }
    
    func exchangeCodeForToken(code: String) {
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "client_id=\(Bundle.main.object(forInfoDictionaryKey: "GitHubClientID") as? String ?? "")&client_secret=\(Bundle.main.object(forInfoDictionaryKey: "GitHubClientSecret") as? String ?? "")&code=\(code)&redirect_uri=\(Bundle.main.object(forInfoDictionaryKey: "CustomScheme") as? String ?? "")://oauth-callback"
        
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("토큰 요청 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("데이터가 없습니다.")
                return
            }
            
            if let accessToken = String(data: data, encoding: .utf8)?.components(separatedBy: "&").first(where: { $0.contains("access_token") })?.components(separatedBy: "=").last {
                self.fetchGitHubUser(accessToken: accessToken)
            } else {
                print("엑세스 토큰을 찾을 수 없습니다.")
            }
        }.resume()
    }
    
    func fetchGitHubUser(accessToken: String) {
        guard let url = URL(string: "https://api.github.com/user") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let githubUser = try? JSONDecoder().decode(GitHubUser.self, from: data) {
                // GitHub의 login을 name으로 설정
                var updatedUser = githubUser
                updatedUser.nickname = githubUser.login
                
                // 이메일 정보 가져오기
                self.fetchGitHubUserEmail(accessToken: accessToken, user: updatedUser)
            }
        }.resume()
    }

    // GitHub 사용자 이메일 가져오기 함수
    func fetchGitHubUserEmail(accessToken: String, user: GitHubUser) {
        guard let emailURL = URL(string: "https://api.github.com/user/emails") else { return }

        var emailRequest = URLRequest(url: emailURL)
        emailRequest.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: emailRequest) { emailData, emailResponse, emailError in
            guard let emailData = emailData, emailError == nil else {
                print("이메일 정보 요청 중 오류 발생: \(emailError?.localizedDescription ?? "알 수 없는 오류")")
                return
            }

            do {
                let emailArray = try JSONDecoder().decode([GitHubEmail].self, from: emailData)
                if let primaryEmail = emailArray.first(where: { $0.primary })?.email {
                    var updatedUser = user
                    updatedUser.email = primaryEmail
                    
                    print("User with email: \(updatedUser)")
                    print("ID Type: \(type(of: updatedUser.id))")

                    
                    // 업데이트된 사용자 정보를 백엔드로 전송
                    self.saveUserToBackend(user: updatedUser)
                } else {
                    print("기본 이메일을 찾을 수 없습니다.")
                }
            } catch {
                print("이메일 정보 파싱 중 오류 발생: \(error.localizedDescription)")
            }
        }.resume()
    }

    
    
    func saveUserToBackend(user: GitHubUser) {
        // Info.plist에서 baseURL 가져오기
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            print("baseURL 가져오기 실패")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/auth/github-login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        
        request.httpBody = try? JSONEncoder().encode(user)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                if let responseObject = try? JSONDecoder().decode(JwtResponse.self, from: data) {
                    saveJWTToKeychain(token: responseObject.jwt)
                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                    }
                }
            } else {
                print("백엔드에 사용자 정보 저장 실패")
            }
        }.resume()
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

struct GitHubUser: Codable {
    let id: Int
    let login: String
    var nickname: String?
    var email: String?
    let avatar_url: String?
}

struct GitHubEmail: Codable {
    let email: String
    let primary: Bool
    let verified: Bool
}

struct JwtResponse: Codable {
    let jwt: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
