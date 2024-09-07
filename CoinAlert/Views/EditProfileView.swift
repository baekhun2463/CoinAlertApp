//
//  EditProfileView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @State private var nickName: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @AppStorage("authToken") var authToken: String?
    
    private func saveNickname() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            errorMessage = "서버 URL을 가져오는 데 실패했습니다."
            return
        }
        
        guard !nickName.isEmpty else {
            errorMessage = "닉네임을 입력해주세요."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let payload: [String: String] = ["nickname": nickName]
        guard let url = URL(string: "\(baseURL)/auth/updateNickname") else {
            errorMessage = "잘못된 URL입니다."
            isLoading = false
            return
        }
        
        guard let token = getJWTFromKeychain() else {
            errorMessage = "인증 토큰을 가져오는 데 실패했습니다."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let httpBody = try JSONSerialization.data(withJSONObject: payload)
            request.httpBody = httpBody
        } catch {
            errorMessage = "요청 데이터를 직렬화하는 데 실패했습니다."
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "오류 발생: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "서버 응답이 없습니다."
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    print("닉네임이 성공적으로 업데이트되었습니다.")
                } else if httpResponse.statusCode == 409 {
                    errorMessage = "중복된 닉네임이 있습니다."
                } else {
                    errorMessage = "닉네임 업데이트 실패: 상태 코드 \(httpResponse.statusCode)"
                }
            }
        }.resume()
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
            errorMessage = "JWT 가져오기 실패: \(status)"
            return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("내 정보 수정")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            TextField("닉네임", text: $nickName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // 에러 메시지 표시
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }
            
            Button(action: {
                saveNickname()
            }) {
                Text("저장")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
