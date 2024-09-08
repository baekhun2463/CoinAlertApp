//
//  Post.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import Foundation

struct Post: Codable, Identifiable {
    var id: Int64
    var title: String
    var content: String
    var timestamp: String
    var likes: Int
    var commentCount: Int
    
    enum CodingKeys: String, CodingKey {
            case id, title, content, timestamp, likes
            case commentCount // JSON 키와 일치시킵니다.
        }
    
    init(id: Int64,title: String, content: String, timestamp: String, likes: Int, commentCount: Int) {
        self.id = id
        self.title = title
        self.content = content
        self.timestamp = timestamp
        self.likes = likes
        self.commentCount = commentCount
    }
}
