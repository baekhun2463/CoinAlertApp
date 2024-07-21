//
//  CommunityView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI

struct CommunityView: View {
    //더미 데이터
    @State private var posts: [Post] = [
        Post(nickName: "gwangurl77", content: "This!!! Also taking a nice stroll along Domino Park after is 🍕", time: "2h", likes: 12, comments: 4),
        Post(nickName: "jiho100x", content: "Don’t let my Italian grandma hear you...", time: "3h", likes: 5, comments: 2),
        Post(nickName: "hidayathere22", content: "I just found out that my neighbor's dog has a better Instagram following than I do. How do I get on that level?", time: "6m", likes: 64, comments: 9)
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(posts) { post in
                    PostView(post: post)
                }
            }
            .navigationBarTitle("Community", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: NewPostView()) {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
            })
        }
    }
}

struct PostView: View {
    var post: Post

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text(post.nickName)
                        .font(.headline)
                    Text(post.time)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "ellipsis")
            }
            Text(post.content)
                .padding(.vertical, 5)
            HStack {
                Button(action: {}) {
                    Image(systemName: "bubble.right")
                    Text("\(post.comments)")
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "heart")
                    Text("\(post.likes)")
                }
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding()
    }
}

struct NewPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var content: String = ""

    var body: some View {
        VStack {
            TextField("What's on your mind?", text: $content)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Spacer()
            Button(action: {
                // Add the new post logic here
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

struct Post: Identifiable {
    let id = UUID()
    let nickName: String
    let content: String
    let time: String
    let likes: Int
    let comments: Int
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}

