import SwiftUI

struct FindUsernameView: View {
    @State private var nickName: String = ""
    @State private var email: String? = nil
    @State private var showMessage: Bool = false
    @State private var message: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("아이디 찾기")
                    .font(.largeTitle)
                    .bold()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("닉네임")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("닉네임을 입력해주세요", text: $nickName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(5)
                }
                
                Button(action: {
                    findEmailByNickName()
                }) {
                    Text("아이디 찾기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                if showMessage {
                    Text(message)
                        .foregroundColor(email == nil ? .red : .green)
                        .font(.caption)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
    
    func findEmailByNickName() {
        guard !nickName.isEmpty else {
            message = "닉네임을 입력해주세요."
            showMessage = true
            return
        }

        guard let url = URL(string: "http://localhost:8080/auth/findEmailByNickName") else {
            message = "유효하지 않은 URL"
            showMessage = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["nickName": nickName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.message = error.localizedDescription
                    self.showMessage = true
                }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.message = "서버로부터 응답이 없습니다."
                    self.showMessage = true
                }
                return
            }

            if httpResponse.statusCode == 200 {
                if let emailResponse = try? JSONDecoder().decode(EmailResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.email = emailResponse.email
                        self.message = "아이디: \(emailResponse.email)"
                        self.showMessage = true

                        // 로그인 뷰로 이동
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                if let window = windowScene.windows.first {
                                    window.rootViewController = UIHostingController(rootView: LoginView())
                                    window.makeKeyAndVisible()
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.message = "잘못된 응답 형식입니다."
                        self.showMessage = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.message = "닉네임이 올바르지 않습니다."
                    self.showMessage = true
                }
            }
        }.resume()
    }
}

struct EmailResponse: Codable {
    let email: String
}

struct FindUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        FindUsernameView()
    }
}
