//
//  ApplicationSettingsStorage.swift
//  SwiftTrader
//
//  Created by Dmitry on 09.03.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
class ApplicationSettingsStorage {
    private var settings: [String : AnyObject] = [:]
    private let storeIdentifier = "ApplicationSettings"
    private enum Attributes {
        case updateTime
        case backgroundFetch
        
        var identifier: String {
            switch self {
            case .updateTime: return "General.UpdateTime"
            case .backgroundFetch: return "General.BackgroundFetch"
            }
        }
    }
    static var DefaultSettings: ApplicationSettingsStorage = {
        let settings = ApplicationSettingsStorage()
        settings.updateTime = 30 //30 seconds
        settings.backgroundFetch = true
        return settings
    }()
    
    var updateTime: TimeInterval {
        get {
            return settings[Attributes.updateTime.identifier] as? TimeInterval ?? ApplicationSettingsStorage.DefaultSettings.updateTime
        }
        set {
            settings[Attributes.updateTime.identifier] = newValue as AnyObject
        }
    }
    
    var backgroundFetch: Bool {
        get {
            return settings[Attributes.backgroundFetch.identifier] as? Bool ?? ApplicationSettingsStorage.DefaultSettings.backgroundFetch
        }
        set {
            settings[Attributes.backgroundFetch.identifier] = newValue as AnyObject
        }
    }
    
    func load() {
        if let storedSettings = UserDefaults.standard.dictionary(forKey: storeIdentifier) as? [String : AnyObject] {
            settings = storedSettings
        }
    }
    
    class func loaded() -> ApplicationSettingsStorage {
        let storage = ApplicationSettingsStorage()
        storage.load()
        return storage
    }
    
    func save() {
        UserDefaults.standard.setValue(settings, forKey: storeIdentifier)
    }
}
