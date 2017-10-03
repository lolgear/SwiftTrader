//
//  NetworkResponseAnalyzer.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation

protocol ResponseSerializer {
    func serialize(data: Data) throws -> Any?
}

class ResponseAnalyzer {
    enum contextKeys: String {
        case reachable
    }
    
    // response result tuple
    typealias ResponseTuple = (AnyObject?, NSError?)
    
    class JSONSerializer: ResponseSerializer {
        func serialize(data: Data) throws -> Any? {
            return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
    }
    
    class XMLSerializer: ResponseSerializer {
        func serialize(data: Data) throws -> Any? {
            return nil
        }
    }
    
    // response serializer
    var serializer: ResponseSerializer = JSONSerializer()
    
    init() {}
}

//MARK: analyzing
extension ResponseAnalyzer {
    // analyze response
    func analyze(response: [String : AnyObject], context: [String : AnyObject]?) -> Response? {
        guard successful(response: response) else {
            return ErrorResponse(dictionary: response)
        }
        // try to recognize result somehow
        return SuccessResponse(dictionary: response)?.blessed()
    }
    
    func analyze(response: Data?, context:[String : AnyObject]?, error: Error?) -> Response? {
        guard error == nil else {
            return ErrorResponse(error: error!)
        }
        
        guard let theResponse = response else {
            return ErrorResponse(error: ErrorFactory.createError(errorType: .responseIsEmpty)!)
        }
        
        
        guard let responseObject = try? serializer.serialize(data: theResponse) as? [String : AnyObject] else {
            return ErrorResponse(error: ErrorFactory.createError(errorType: .couldNotParse(theResponse as AnyObject?))!)
        }
        return self.analyze(response: responseObject!, context: context)
    }
    
    func successful(response: [String : AnyObject]?) -> Bool {
        if let status = response?["success"] as? Bool {
            return status
        }
        return false
    }
}
