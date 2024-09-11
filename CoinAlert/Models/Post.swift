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
        case id, title, content, timestamp, likes
        case commentCount // JSON 키와 일치시킵니다.
        case isLiked
        case comments
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
    var post_id: Int64 // postId 필드 추가
    var member_id: Int64 // memberId 필드 추가
}
