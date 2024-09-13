//
//  NewPostView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI

struct NewPostView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @State private var nickName: String = "" // 닉네임을 서버에서 가져오기 때문에 초기값은 빈 문자열
    @State private var content: String = ""
    @State private var title: String = ""
    @State private var showAlert: Bool = false
    @State private var showLoginView: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            // 헤더 이미지 추가
            Image("post_background")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .overlay(
                    Text("Create a New Post")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding()
                    , alignment: .bottom
                )
            
            // 타이틀 입력 필드
            VStack(alignment: .leading, spacing: 10) {
                Text("제목")
                    .font(.headline)
                    .foregroundColor(.gray)
                TextField("Enter your post title", text: $title)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.top, 20)

            // 컨텐츠 입력 필드
            VStack(alignment: .leading, spacing: 10) {
                Text("내용")
                    .font(.headline)
                    .foregroundColor(.gray)
                TextEditor(text: $content)
                    .frame(minHeight: 200)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
            .padding(.top, 10)

            Spacer()

            // 포스트 버튼
            Button(action: {
                savePost()
            }) {
                Text("Post")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Something went wrong"), dismissButton: .default(Text("OK")))
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitle("새 글 작성", displayMode: .inline)
    }

    // POST 저장 로직
    private func savePost() {
        guard !title.isEmpty, !content.isEmpty else {
            errorMessage = "제목이나 내용이 비었습니다."
            showAlert = true
            return
        }
        
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            return
        }
        
        guard let token = getJWTFromKeychain() else { return }

        fetchCurrentUser()
        
        let postData = PostData(author: nickName, title: title, content: content)

        guard let url = URL(string: "\(baseURL)/posts/newPost") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        
        do {
            let jsonData = try JSONEncoder().encode(postData)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Failed to encode post data."
            showAlert = true
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to save post: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 201 {
                // 성공적으로 저장되었을 때 처리
                DispatchQueue.main.async {
                    self.title = ""
                    self.content = ""
                    // 성공 메시지 표시
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to save post: Unexpected response."
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    func fetchCurrentUser() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            errorMessage = "서버 URL을 가져오는 데 실패했습니다."
            return
        }
        
        guard let token = getJWTFromKeychain() else {
            errorMessage = "인증 토큰을 가져오는 데 실패했습니다."
            return
        }
        
        guard let url = URL(string: "\(baseURL)/auth/getNickname") else {
            errorMessage = "잘못된 URL입니다."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "오류 발생: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    errorMessage = "닉네임을 가져오는 데 실패했습니다."
                    return
                }

                if let data = data, let result = try? JSONDecoder().decode(NicknameResponse.self, from: data) {
                    nickName = result.nickname
                } else {
                    errorMessage = "데이터를 파싱하는 데 실패했습니다."
                }
            }
        }.resume()
    }
    
    private func getJWTFromKeychain() -> String? {
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
}

struct PostData: Encodable {
    let author: String
    let title: String
    let content: String
}


#Preview {
    NewPostView()
}
