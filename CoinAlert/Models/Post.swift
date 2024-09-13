import Foundation

struct Post: Decodable, Identifiable {
    var id: Int64
    var title: String
    var content: String
    var timestamp: String
    var likes: Int
    var commentCount: Int
    var isLiked: Bool?
    var comments: [PostComment]

    enum CodingKeys: String, CodingKey {
        case id, title, content, timestamp, likes, commentCount, isLiked, comments
    }

    init(id: Int64, title: String, content: String, timestamp: String, likes: Int, commentCount: Int, isLiked: Bool, comments: [PostComment]) {
        self.id = id
        self.title = title
        self.content = content
        self.timestamp = timestamp
        self.likes = likes
        self.commentCount = commentCount
        self.isLiked = isLiked
        self.comments = comments
    }
}

struct PostComment: Identifiable, Codable {
    var id: Int
    var content: String
    var author: String
    var likes: Int
    var liked: Bool
    var postId: Int64? // `postId`로 이름 변경

    enum CodingKeys: String, CodingKey {
        case id, content, author, likes, liked
        case postId = "post_id" // JSON 키를 매핑
    }
}
