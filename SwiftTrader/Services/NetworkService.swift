//
//  NetworkService.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Network
import Foundation
class NetworkService: BaseService {
    lazy var client: APIClient = APIClient()
}

extension NetworkService {
    override var health: Bool {
        return client.reachabilityManager.reachable
    }
}

extension NetworkService {
    override func setup() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        client.reachabilityManager.startMonitoring()
    }
}
