//
//  PostView.swift
//  CoinAlert
//
//  Created by 백지훈 on 9/7/24.
//

import SwiftUI

struct PostView: View {
    // 샘플 데이터 - 실제 앱에서는 데이터베이스나 서버에서 데이터를 가져오도록 합니다.
    var postTitle: String = "Sample Post Title"
    var postContent: String = "This is a sample post content. It should describe something interesting and engaging for the readers."
    var postAuthor: String = "John Doe"
    var postTimestamp: String = "September 7, 2024"
    var postLikes: Int = 42
    var comments: [Comment] = [
        Comment(id: 1, author: "Alice", content: "Great post!", likes: 5),
        Comment(id: 2, author: "Bob", content: "Thanks for sharing!", likes: 3),
        Comment(id: 3, author: "Charlie", content: "Interesting perspective.", likes: 2)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 게시글 섹션
                VStack(alignment: .leading, spacing: 10) {
                    Text(postTitle)
                        .font(.title)
                        .bold()
                        .padding(.bottom, 5)
                    
                    HStack {
                        Text("by \(postAuthor)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(postTimestamp)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Text(postContent)
                        .font(.body)
                        .padding(.top, 5)
                    
                    HStack {
                        Button(action: {
                            // 좋아요 로직 추가
                        }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                Text("\(postLikes) Likes")
                            }
                            .foregroundColor(.red)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                
                // 댓글 섹션
                Text("Comments")
                    .font(.headline)
                    .padding(.leading)
                
                ForEach(comments, id: \.id) { comment in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(comment.author)
                                .font(.subheadline)
                                .bold()
                            Spacer()
                            Text("\(comment.likes) Likes")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(comment.content)
                            .font(.body)
                            .padding(.top, 2)
                        
                        Divider()
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationBarTitle("Post", displayMode: .inline)
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

// 댓글 모델 정의
struct Comment {
    let id: Int
    let author: String
    let content: String
    let likes: Int
}

#Preview {
    PostView()
}
