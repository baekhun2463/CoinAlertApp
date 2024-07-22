//
//  LoginView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI
import SwiftData
import SwiftJWT
import Security
import Combine

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoggedIn: Bool = false
    @State private var loginFailed: Bool = false
    @State private var jwt: String?
    
    @Environment(\.modelContext) private var modelContext: ModelContext
    
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
            .navigationDestination(isPresented: $isLoggedIn) {
                MainTabView()
            }
            .onAppear {
                if let token = getJWT(forKey: "userJWT") {
                    print("키체인에서 가져온 JWT: \(token)")
                } else {
                    print("키체인에서 JWT를 가져오지 못했습니다.")
                }
            }
        }
    }
    
    func login() {
        let predicate = #Predicate<User> { $0.email == email && $0.password == password }
        let fetchDescriptor = FetchDescriptor<User>(predicate: predicate)
        
        do {
            let users = try modelContext.fetch(fetchDescriptor)
            if users.isEmpty {
                loginFailed = true
            } else {
                if let user = users.first {
                    if let token = generateJWT(for: user) {
                        self.jwt = token
                        print("JWT: \(token)")
                        let saveResult = saveJWT(token, forKey: "userJWT")
                        print("JWT save result: \(saveResult)")
                        isLoggedIn = true
                        loginFailed = false
                    } else {
                        loginFailed = true
                    }
                }
            }
        } catch {
            print("로그인 에러: \(error)")
            loginFailed = true
        }
    }
    
    func generateJWT(for user: User) -> String? {
        let expirationDate = Date(timeIntervalSinceNow: 72000)
        let claims = MyClaims(sub: user.id.uuidString, email: user.email, exp: expirationDate)
        var jwt = JWT(claims: claims)
        
        guard let key = getSecretKey() else {
            print("비밀 키를 가져올 수 없습니다.")
            return nil
        }
        
        let signer = JWTSigner.hs256(key: Data(key.utf8))
        
        do {
            let signedJWT = try jwt.sign(using: signer)
            return signedJWT
        } catch {
            print("JWT 생성 에러: \(error)")
            return nil
        }
    }
    
    func getSecretKey() -> String? {
        return getKeychainItem(forKey: "SECRET_KEY")
    }
    
    func saveJWT(_ jwt: String, forKey key: String) -> Bool {
        guard let data = jwt.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // 기존 항목이 있는 경우 삭제
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getJWT(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let data = item as? Data, let jwt = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jwt
    }
    
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

struct MyClaims: Claims {
    var sub: String
    var email: String
    var exp: Date
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

