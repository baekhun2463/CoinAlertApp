//
//  User.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import Foundation
import SwiftData

@Model
class User {
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute var nickName: String
    @Attribute var email: String
    @Attribute var password: String
    
    @Relationship var priceData: [PriceData]?
    @Relationship var posts: [Post]?
    
    init(nickName: String = "", email: String, password: String) {
        self.nickName = nickName
        self.email = email
        self.password = password
    }
}
