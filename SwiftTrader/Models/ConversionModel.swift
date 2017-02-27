//
//  ConversionModel.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 26.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
struct ConversionModel {
    var fromCode: String?
    var toCode: String?
    
    enum Errors: Int {
        static let domain = "com.opensource.business.swift_trader"
        case missing
        case equal
        var message: String {
            switch self {
            case .missing: return "One of components is missing"
            case .equal: return "Components can not be equal"
            }
        }
        var error: Error? {
            return NSError(domain: Errors.domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey : message])
        }
    }
    var error: Error? {
        if fromCode == nil || toCode == nil {
            return Errors.missing.error
        }
        
        if fromCode == toCode {
            return Errors.equal.error
        }
        
        return nil
    }
}
