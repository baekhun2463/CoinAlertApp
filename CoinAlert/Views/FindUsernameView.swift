//
//  FindUsernameView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI
import SwiftData

struct FindUsernameView: View {
    @State private var nickName: String = ""
    @State private var email: String? = nil
    @State private var showMessage: Bool = false
    @State private var message: String = ""
    
    @Environment(\.modelContext) private var modelContext: ModelContext
    
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
        let predicate = #Predicate<User> { $0.nickName == nickName }
        let fetchDescriptor = FetchDescriptor<User>(predicate: predicate)
        
        do {
            let users = try modelContext.fetch(fetchDescriptor)
            if let user = users.first {
                email = user.email
                message = "아이디: \(user.email)"
                showMessage = true
                
                // 로그인 뷰로 이동
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        if let window = windowScene.windows.first {
                            window.rootViewController = UIHostingController(rootView: LoginView())
                            window.makeKeyAndVisible()
                        }
                    }
                }
            } else {
                email = nil
                message = "잘못된 닉네임입니다."
                showMessage = true
            }
        } catch {
            email = nil
            message = "아이디 찾기 에러: \(error)"
            showMessage = true
        }
    }
}

struct FindUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        FindUsernameView()
    }
}
