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
    
    public static var baseCode: String {
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
    public class func fetchConversions(delegate: NSFetchedResultsControllerDelegate, context: NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        return Conversion.ldm_fetchAllSorted(by: "addedAt", ascending: true, with: nil, groupBy: nil, delegate: delegate, context: context)
    }
    public class func fetchQuotes(delegate: NSFetchedResultsControllerDelegate, context: NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        return Quote.ldm_fetchAllSorted(by: "targetCode", ascending: true, with: nil, groupBy: nil, delegate: delegate, context: context)
    }
    
    public class func currencies(context: NSManagedObjectContext) -> [String] {
        return Quote.currencies(context: context).sorted()
    }
}

//MARK: Contexts
extension DatabaseSupplement {
    class func newConfinementContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext.mr_confinement()
        let workingName = context.mr_workingName().appending(" \(stackName())");
        context.mr_setWorkingName(workingName)
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    class func stackName() -> String {
        return "Database"
    }
    public class func defaultContext(coordinator: NSPersistentStoreCoordinator?) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.mr_setWorkingName("Main Queue Context \(stackName())")
        return context
    }
}

//MARK: Save
extension DatabaseSupplement {
    class func confinementContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext.mr_confinement()
        let workingName = context.mr_workingName().appending(" Database");
        context.mr_setWorkingName(workingName)
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    public class func save(block:@escaping ((NSManagedObjectContext?) -> Void), context: NSManagedObjectContext, completion: ((Bool, Error?) -> Void)?) {
        let identifier = #function
        save(block: block, context: context, identifier: identifier, completion: completion)
    }
    
    class func save(block:@escaping ((NSManagedObjectContext?) -> Void), context theContext: NSManagedObjectContext, identifier: String, completion: ((Bool, Error?) -> Void)?) {
        MR_saveQueue().async {
            autoreleasepool {
//                block(theContext)
                let context = self.confinementContext()
                context.persistentStoreCoordinator = theContext.persistentStoreCoordinator
                context.mr_setWorkingName(identifier)
                block(context)
                let saveOptions: MRContextSaveOptions = [.saveParentContexts, .saveSynchronously]
                let currentCompletion: (Bool, Error?) -> () = { (result, error) in
                    completion?(result, error)
                }
                theContext.mr_save(options: saveOptions, completion: currentCompletion)
            }
        }
    }
}
