//
//  NetworkConfiguration.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
public struct Configuration {
    public var serverAddress:String = "http://apilayer.net/api"
    public var apiAccessKey:String = ""
    public init(serverAddress theServerAddress: String, apiAccessKey theApiAccessKey: String) {
        serverAddress = theServerAddress
        apiAccessKey = theApiAccessKey
    }
    public init(apiAccessKey theApiAccessKey: String) {
        apiAccessKey = theApiAccessKey
    }
    public init() {}
}
