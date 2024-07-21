//
//  NewPostView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI
import SwiftData

struct NewPostView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) var modelContext: ModelContext
    
    @State private var content: String = ""
    @State private var title: String = ""
    @State private var showAlert: Bool = false
    @State private var showLoginView: Bool = false
    @State private var errorMessage: String?
    
    
    
    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("What's on your mind?", text: $content)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Spacer()
            Button(action: {
                let newPost = Post(title: title, content: content, timestamp: Date())
                modelContext.insert(newPost)
                do {
                    try modelContext.save()
                }catch {
                    errorMessage = "실패 : \(error.localizedDescription)"
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Post")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarTitle("New Post", displayMode: .inline)
    }
}


#Preview {
    NewPostView()
        .modelContainer(for: Post.self, inMemory: true)
}
