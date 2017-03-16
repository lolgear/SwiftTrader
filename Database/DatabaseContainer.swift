//
//  DatabaseContainer.swift
//  SwiftTrader
//
//  Created by Dmitry on 09.03.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import CoreData
import EncryptedCoreData

public protocol DatabaseContainerProtocol {
    func checkStack() -> Bool
    func viewContext() -> NSManagedObjectContext?
    func save(block:@escaping ((NSManagedObjectContext?) -> Void), completion: ((Bool, Error?) -> Void)?)
    func setup()
}

public class DatabaseContainer: DatabaseContainerProtocol {
    init() {
    }
    
    public func checkStack() -> Bool {
        return false
    }
    
    public func viewContext() -> NSManagedObjectContext? {
        return nil
    }

    public func save(block:@escaping ((NSManagedObjectContext?) -> Void), completion: ((Bool, Error?) -> Void)?) {
        guard checkStack() else {
            return
        }
        performBackgroundTask { (backgroundContext) in
            do {
                try autoreleasepool {
                    block(backgroundContext)
                    //        DatabaseSupplement.save(block: block, context: theContext, completion: completion)
                    try backgroundContext.save()
                    completion?(true, nil)
                }
            }
            catch let error {
                completion?(false, error)
            }
        }
    }
    
    public func setup() {}
    public class func container() -> DatabaseContainerProtocol? {
        if #available(iOS 10, *) {
            return DatabaseContainerModern()
        }
        return DatabaseContainerPrior10()
    }
    
    // Protected
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Swift.Void) {
        
    }
}

extension DatabaseContainer {
    func getBundle() -> Bundle? {
        return Bundle(for: DatabaseContainer.self)
    }
    func getLibraryDirectoryUrl() -> URL? {
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return urls.count > 0 ? urls[urls.count - 1] : nil
    }

    func getDatabaseName() -> String? {
        return getBundle()?.infoDictionary?[kCFBundleNameKey as String] as? String
    }

    func getDatabaseExtension() -> String? {
        return "sqlite"
    }
    func getDatabaseUrl() -> URL? {
        guard let url = self.getLibraryDirectoryUrl(), let databaseName = getDatabaseName(), let databaseExtension = getDatabaseExtension() else {
            return nil
        }
        
        return url.appendingPathComponent(databaseName).appendingPathExtension(databaseExtension)
    }
    
    
    func getManagedObjectModel() -> NSManagedObjectModel? {
        guard let url = getBundle()?.url(forResource: "Database", withExtension: "momd") else {
            return nil
        }
        return NSManagedObjectModel(at: url)
    }
}

@available(iOS 10, *)
class DatabaseContainerModern: DatabaseContainer {
    public override func checkStack() -> Bool {
        return accidentError == nil && container != nil
    }
    
    override func viewContext() -> NSManagedObjectContext? {
        return container?.viewContext
    }
    
    public override func setup() {
        container = getPersistentStoreContainer()
    }
    
    var accidentError: Error?
    var container: NSPersistentContainer?
    func getPersistentStoreContainer() -> NSPersistentContainer? {
        guard let databaseName = getDatabaseName() else {
            return nil
        }
        
        guard let model = getManagedObjectModel() else {
            return nil
        }
        
        guard let databaseUrl = getDatabaseUrl() else {
            return nil
        }
        
        let container = NSPersistentContainer(name: databaseName, managedObjectModel: model)
        
        let storeDescription = NSPersistentStoreDescription(url: databaseUrl)
        storeDescription.type = EncryptedStoreType
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores(completionHandler: {
            [unowned self]
            (description, error) in
            self.accidentError = error
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
    
    override func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container?.performBackgroundTask(block)
    }
}

class DatabaseContainerPrior10: DatabaseContainer {
    public override func checkStack() -> Bool {
        return accidentError == nil && self.coordinator != nil
    }
    
    override func viewContext() -> NSManagedObjectContext? {
        return mainContext
    }
    
    public override func setup() {
        coordinator = getPersistentStoreCoordinator()
        mainContext = getMainContext()
    }
    
    var accidentError: Error?
    var coordinator: NSPersistentStoreCoordinator?
    var mainContext: NSManagedObjectContext?
    //MARK: Old setup
    func getPersistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        guard let managedObjectModel = self.getManagedObjectModel() else {
            return nil
        }
        
        guard let databaseUrl = self.getDatabaseUrl() else {
            return nil
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel:
            managedObjectModel)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseUrl, options: [NSMigratePersistentStoresAutomaticallyOption: true,                                                                                                                    NSInferMappingModelAutomaticallyOption: true])
        }
        catch let error {
            accidentError = error
        }
        
        return coordinator
    }
    
    func getMainContext() -> NSManagedObjectContext? {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.coordinator
        return context
    }
    
    func getBackgroundContext() -> NSManagedObjectContext? {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.viewContext()
        return context
    }
    
    override func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Swift.Void) {
        guard let context = self.getBackgroundContext() else {
            return
        }
        
        context.perform {
            block(context)
        }
    }
}
