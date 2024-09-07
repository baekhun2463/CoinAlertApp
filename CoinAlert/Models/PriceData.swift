import Foundation

struct PriceData: Codable {
    var id: Int64? // 서버에서 null 값을 받을 수 있으므로 Optional로 설정
    var price: Double // 메인 탭에서 사용될 값
    var date: String // JSONDecoder의 dateDecodingStrategy에 맞게 날짜를 디코딩
    var isTriggered: Bool
    var alertPrice: Double
    var memberId: Int64?

    // 기본 생성자
    init(id: Int64? = nil, price: Double, date: String, isTriggered: Bool = false, alertPrice: Double, memberId: Int64? = nil) {
        self.id = id
        self.price = price
        self.date = date
        self.isTriggered = isTriggered
        self.alertPrice = alertPrice
        self.memberId = memberId
    }
}
