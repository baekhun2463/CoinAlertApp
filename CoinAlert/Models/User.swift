//
//  User.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import Foundation

struct User: Codable {
    var id: Int64?
    var nickname: String
    var email: String
    var password: String

    init(id: Int64? = nil, nickname: String, email: String, password: String) {
        self.id = id
        self.nickname = nickname
        self.email = email
        self.password = password
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case nickname = "nickname"
        case email = "email"
        case password = "password"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int64.self, forKey: .id)
        nickname = try container.decode(String.self, forKey: .nickname)
        email = try container.decode(String.self, forKey: .email)
        password = try container.decode(String.self, forKey: .password)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
    }
}
