//
//  User.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import Foundation

struct User: Codable {
    var nickName: String
    var email: String
    var password: String
    var token: String = ""
    
    
    init(nickName: String, email: String, password: String, token: String = "") {
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
        nickName = try container.decode(String.self, forKey: .nickName)
        email = try container.decode(String.self, forKey: .email)
        password = try container.decode(String.self, forKey: .password)
        token = try container.decode(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nickName, forKey: .nickName)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encode(token, forKey: .token)
    }
}
