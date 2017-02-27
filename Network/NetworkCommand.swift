//
//  NetworkCommand.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//
import Alamofire
import Foundation
public class Command {
//    var shouldStopError: NSError? {
//        return Network.ErrorFactory.createError(errorMessage: shouldStopMessage)
//    }
    public init() {
    }
    
    var shouldStop: Bool {
        return shouldStopMessage != nil
    }

    var shouldStopMessage: String?

    // override by subclasses
    var method: Alamofire.HTTPMethod = .get
    var path: String = ""
    var authorized: Bool = true
    func queryParameters() -> [String : AnyObject]? {
        return [:]
    }
}

// Endpoint : { /list }
// Params : {
//    "access_key" : "YOUR_ACCESS_KEY"
// }
public class APICommand : Command {
    override func queryParameters() -> [String : AnyObject]? {
        var result = super.queryParameters()
        result?["access_key"] = Configuration.apiAccessKey as AnyObject?
        return result
    }
}
public class ListCurrenciesCommand : APICommand {
    public override init() {
        super.init()
        path = "list"
    }
}
public class LiveRatesCommand : APICommand {
    public override init() {
        super.init()
        path = "live"
    }
}
public class HistoricalRatesCommand : APICommand {
    public override init() {
        super.init()
        path = "historical"
    }
}
