//
//  DatabaseErrors.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
enum Errors {
    static let domain = "org.opensource.database.swift_trader"
    case invalidPair(String, String)
    case pairExists(String, String)
    var code: Int {
        switch self {
        case .invalidPair(_, _): return -300
        case .pairExists(_, _): return -301
        }
    }
    var message: String {
        switch self {
        case let .invalidPair(lhs, rhs): return "Invalid pair(\(lhs) , \(rhs))! Same items can not be proceeded!"
        case let .pairExists(lhs, rhs): return "Pair(\(lhs), \(rhs)) already exists!"
        }
    }
    var error: Error {
        return NSError(domain: type(of: self).domain, code: code, userInfo: [NSLocalizedDescriptionKey : message])
    }
}
