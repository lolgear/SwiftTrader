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
    private let attributeUpdateTime = "General.UpdateTime"
    static var DefaultSettings: ApplicationSettingsStorage = {
        let settings = ApplicationSettingsStorage()
        settings.updateTime = 30 //30 seconds
        return settings
    }()
    var updateTime: TimeInterval {
        get {
            return settings[attributeUpdateTime] as? TimeInterval ?? ApplicationSettingsStorage.DefaultSettings.updateTime
        }
        set {
            settings[attributeUpdateTime] = newValue as AnyObject
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
