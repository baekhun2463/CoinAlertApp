//
//  Comment.swift
//  CoinAlert
//
//  Created by 백지훈 on 9/10/24.
//
import Foundation

struct Comment: Identifiable, Decodable {
    var id: Int
    var content: String
    var author: String
    var likes: Int
}
