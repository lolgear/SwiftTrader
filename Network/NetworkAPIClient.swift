//
//  NetworkAPIClient.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Alamofire
import Foundation

public class APIClient {
    public init () {}
    lazy var analyzer = ResponseAnalyzer()
    public lazy var reachabilityManager = ReachabilityManager(targetHost: Configuration.serverAddress)
    func URLComponents(strings : String ...) -> String {
        return strings.joined(separator: "/")
    }
    
    func fullURL(path : String) -> String {
        return URLComponents(strings: Configuration.serverAddress, path)
    }
    
    func executeOperation(method : Alamofire.HTTPMethod, path: String, parameters: [String : AnyObject]?, onResponse : @escaping (Response) -> ()) {
        let url = fullURL(path: path)
        
        Alamofire.SessionManager.default.request(url, method: method, parameters: parameters).responseJSON { (response) in
            // case class?
            // case class is what?
            let error = response.error
            let data = response.data
            let response = self.analyzer.analyze(response: data, context: nil, error: error) ?? ErrorResponse(error: ErrorFactory.createError(errorType: .unknown)!)
            onResponse(response)
        }
    }
    
    public func executeCommand(command : Command, onResponse : @escaping (Response) -> ()) {
        let method = command.method
        let path = command.path
        let parameters = command.queryParameters()
        executeOperation(method: method, path: path, parameters: parameters, onResponse: onResponse)
    }
}
