//
//  NetworkErrorFactory.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
public class ErrorFactory {
    public enum Errors {
        case couldNotConnectToServer
        case responseIsEmpty        
        case unknown
        case couldNotParse(AnyObject?)
        case theInternal(AnyObject?)
        var code : Int {
            switch self {
            case .couldNotConnectToServer: return -100
            case .responseIsEmpty: return -101
            case .unknown: return -102
            case .couldNotParse(_): return -103
            case .theInternal: return -104
            }
        }
        var message : String {
            switch self {
            case .couldNotConnectToServer: return "could not connect to server!"
            case .responseIsEmpty: return "aware! response is empty!"
            case .unknown: return "something wrong? unknown"
            case let .couldNotParse(item): return "could not parse item: \(String(describing: item))"
            case let .theInternal(item): return "internal error: \(String(describing: item))"
            }
        }
    }
    
    // MARK: Constants
    public static let domain: String = "com.opensource.network.swift_trader"
    
    // MARK: Create errors
    public static func createError(errorType type:Errors) -> Error? {
        return createError(message: type.message, code: type.code)
    }
    
    static func createError(message: String?, code: Int) -> Error? {
        guard let description = message else {
            return nil
        }
        let error = NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey : description])
        return createError(error: error as Error)
    }
    
    static func createError(error: Error?) -> Error? {
        guard let theError = error else {
            return nil
        }
        return customizeError(error: theError)
    }
    
    // MARK: Handle custom errors
    static func customizeError(error: Error) -> Error {
        return error
    }
}
