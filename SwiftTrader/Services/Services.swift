//
//  Services.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

protocol ServicesInfoProtocol {
    var health: Bool {get}
    static var name: String {get}
}

protocol ServicesSetupProtocol {
    func setup()
    func tearDown()
}

class BaseService: NSObject {
    
}

extension BaseService: ServicesInfoProtocol {
    @objc var health: Bool {
        return false
    }
    static var name: String {
        return self.description()
    }
}

extension BaseService: ServicesSetupProtocol {
    @objc func setup() {}
    @objc func tearDown() {}
}

extension BaseService: UIApplicationDelegate {
    
}

class ServicesManager: NSObject {
    var services: [BaseService] = []
    static var manager: ServicesManager {
        return (UIApplication.shared.delegate as! AppDelegate).servicesManager
    }
    override init() {
        services = [LoggingService(), NetworkService(), DatabaseService(), DataProviderService()]
    }
    func service(name: String) -> BaseService? {
        return services.filter {type(of: $0).name == name}.first
    }
    func setup() {
        for service in services as [ServicesSetupProtocol] {
            service.setup()
        }
    }
    func tearDown() {
        for service in services as [ServicesSetupProtocol] {
            service.tearDown()
        }
    }
}

//MARK: Accessors
extension ServicesManager {
    var databaseService: DatabaseService? {
        return service(name: DatabaseService.name) as? DatabaseService
    }
    var dataProviderService: DataProviderService? {
        return service(name: DataProviderService.name) as? DataProviderService
    }
    var networkService: NetworkService? {
        return service(name: NetworkService.name) as? NetworkService
    }
    var loggingService: LoggingService? {
        return service(name: LoggingService.name) as? LoggingService
    }
}

extension ServicesManager: UIApplicationDelegate {
    func servicesUIDelegates() -> [UIApplicationDelegate] {
        return services as [UIApplicationDelegate]
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        tearDown()
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        setup()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationDidBecomeActive?(application)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationWillResignActive?(application)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationDidEnterBackground?(application)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationWillEnterForeground?(application)
        }
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        for service in servicesUIDelegates() {
            service.application?(application, performFetchWithCompletionHandler: completionHandler)
        }
    }
    
}
