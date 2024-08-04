//
//  User.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import Foundation

struct User: Codable {
    var id: UUID?
    var nickName: String
    var email: String
    var password: String
    var token: String
    
    init(id: UUID? = nil, nickName: String, email: String, password: String, token: String = "") {
        self.id = id
        self.nickName = nickName
        self.email = email
        self.password = password
        self.token = token
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case nickName = "nickName"
        case email = "email"
        case password = "password"
        case token = "token"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        nickName = try container.decode(String.self, forKey: .nickName)
        email = try container.decode(String.self, forKey: .email)
        password = try container.decode(String.self, forKey: .password)
        token = try container.decode(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(nickName, forKey: .nickName)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encode(token, forKey: .token)
    }
}
