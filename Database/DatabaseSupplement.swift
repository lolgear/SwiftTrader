//
//  DatabaseSupplement.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord
public class DatabaseSettings {
    private class DatabaseSettingsCompanion {
        static let storeName = "DatabaseSettings"
        static let attributeBaseCode = "baseCode"
    }
    
    public class var baseCode: String {
        get{
            let propertyName = DatabaseSettingsCompanion.attributeBaseCode
            return UserDefaults.standard.string(forKey: propertyName) ?? ""
        }
        set{
            let propertyName = DatabaseSettingsCompanion.attributeBaseCode
            UserDefaults.standard.set(newValue, forKey: propertyName)
        }
    }
}

public class DatabaseSupplement {
    public init() {}
}

//MARK: Fetch
extension DatabaseSupplement {
    public func fetchConversions(delegate: NSFetchedResultsControllerDelegate, context: NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        return Conversion.ldm_fetchAllSorted(by: "addedAt", ascending: true, with: nil, groupBy: nil, delegate: delegate, context: context)
    }
    public func fetchQuotes(delegate: NSFetchedResultsControllerDelegate, context: NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        return Quote.ldm_fetchAllSorted(by: "targetCode", ascending: true, with: nil, groupBy: nil, delegate: delegate, context: context)
    }
    
    public func currencies(context: NSManagedObjectContext) -> [String] {
        return Quote.currencies(context: context).sorted()
    }
}
