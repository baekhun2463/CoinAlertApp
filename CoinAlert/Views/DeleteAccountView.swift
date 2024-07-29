//
//  DeleteAccountView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI
import SwiftData

struct DeleteAccountView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("authToken") var authToken: String?
    @State private var navigateToLogin = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("계정 탈퇴")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            Text("계정을 탈퇴하면 복구할 수 없습니다. 정말로 탈퇴하시겠습니까?")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            
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
            
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
            
            Spacer()
        }
        .padding()
    }
    
    func deleteAccount() {
        guard let token = authToken else { return }
        
        let predicate = #Predicate<User> { $0.token == token }
        let fetchDescriptor = FetchDescriptor<User>(predicate: predicate)
        
        do {
            let users = try modelContext.fetch(fetchDescriptor)
            if let user = users.first {
                // 연결된 PriceData 및 Post 삭제
                if !user.priceData.isEmpty {
                    for priceData in user.priceData {
                        modelContext.delete(priceData)
                    }
                }
                
                if !user.posts.isEmpty {
                    for post in user.posts {
                        modelContext.delete(post)
                    }
                }
                
                // User 삭제
                modelContext.delete(user)
                
                // 저장
                try modelContext.save()
                
                // 로그아웃
                isLoggedIn = false
                authToken = nil
            }
        } catch {
            print("계정 삭제 에러: \(error)")
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView()
    }
}
