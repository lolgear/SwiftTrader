//
//  NetworkService.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import NetworkWorm
import Foundation
import UIKit

class NetworkService: BaseService {
    var client: APIClient!
    fileprivate func clientConfiguration() -> Configuration {
        return Configuration(apiAccessKey: ApplicationSettingsStorage.loaded().networkAPIKey)
    }
}

extension NetworkService {
    override var health: Bool {
        return client.reachabilityManager?.reachable ?? false
    }
}

extension NetworkService {
    override func setup() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        client = APIClient(configuration: clientConfiguration())
        client.reachabilityManager?.startMonitoring()
    }
}

// React on settings did updated.
// Use event machine?
extension NetworkService {
    func updateClient() {
        let configuration = clientConfiguration()
        LoggingService.logVerbose("\(self) \(#function) reload configuration: \(configuration)")
        client.update(configuration: configuration)
    }
}
