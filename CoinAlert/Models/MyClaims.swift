//
//  MyClaims.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import Foundation
import SwiftJWT

struct MyClaims: Claims {
    var sub: String
    var email: String
    var exp: Date
}
