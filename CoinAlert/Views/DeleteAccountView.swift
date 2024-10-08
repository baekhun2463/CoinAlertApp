import SwiftUI
import Security

struct DeleteAccountView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("authToken") var authToken: String?
    @State private var accountDeleted: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("계정 탈퇴")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                Text("계정을 탈퇴하면 복구할 수 없습니다. 정말로 탈퇴하시겠습니까?")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    deleteAccount()
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
            .navigationDestination(isPresented: $accountDeleted) {
                LoginView()
            }
        }
    }

    func deleteAccount() {
        guard let token = getJWTFromKeychain() else { return }
        
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            print("baseURL 가져오기 실패")
            return
        }
        
        print("Base URL: \(baseURL)")
        print(token)

        guard let url = URL(string: "\(baseURL)/auth/deleteAccount") else {
            errorMessage = "유효하지 않은 URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "서버로부터 응답이 없습니다."
                }
                return
            }

            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                    self.authToken = nil
                    self.accountDeleted = true
                    deleteJWTFromKeychain()
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "계정 삭제에 실패했습니다."
                }
            }
        }.resume()
    }
}

func getJWTFromKeychain() -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "authToken",
        kSecReturnData as String: kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    
    if status == errSecSuccess, let data = item as? Data {
        return String(data: data, encoding: .utf8)
    } else {
        print("JWT 가져오기 실패: \(status)")
        return nil
    }
}

func deleteJWTFromKeychain() {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "authToken"
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    if status == errSecSuccess {
        print("JWT 삭제 성공")
    } else {
        print("JWT 삭제 실패: \(status)")
    }
}


struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView()
    }
}

