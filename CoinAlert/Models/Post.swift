//
//  Post.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import Foundation
import SwiftData

@Model
class Post {
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute var title: String
    @Attribute var content: String
    @Attribute var timestamp: Date
    @Attribute var likes: Int
    @Attribute var comments: Int
    
    @Relationship var user: User?

    init(title: String, content: String, timestamp: Date, likes: Int = 0, comments: Int = 0, user: User? = nil) {
        self.title = title
        self.content = content
        self.timestamp = timestamp
        self.likes = likes
        self.comments = comments
        self.user = user
    }
}
