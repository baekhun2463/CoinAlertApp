import Foundation

struct Post: Decodable, Identifiable {
    var id: Int64
    var title: String
    var content: String
    var timestamp: String
    var likes: Int
    var commentCount: Int
    var isLiked: Bool?
    var comments: [PostComment]  // 'Comment' 대신 'PostComment'로 변경합니다.
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, timestamp, likes, commentCount, isLiked, comments
    }
    
    // 기본 생성자 추가
    init(id: Int64, title: String, content: String, timestamp: String, likes: Int, commentCount: Int, isLiked: Bool?, comments: [PostComment]) {
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

// Comment 구조체의 이름을 'PostComment'로 변경하여 모호성 문제를 해결합니다.
struct PostComment: Identifiable, Decodable {
    var id: Int
    var content: String
    var likes: Int
}
