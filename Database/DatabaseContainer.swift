//
//  DatabaseContainer.swift
//  SwiftTrader
//
//  Created by Dmitry on 09.03.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import CoreData
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
    func getLibraryDirectoryUrl() -> URL? {
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return urls.count > 0 ? urls[urls.count - 1] : nil
    }

    func getDatabaseName() -> String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Database"
    }

    func getDatabaseUrl() -> URL? {
        guard let url = self.getLibraryDirectoryUrl() else {
            return nil
        }
        
        let databaseName = getDatabaseName()
        let result = url.appendingPathComponent(databaseName).appendingPathExtension("sqlite")
        
        return result
    }
    
    
    func getManagedObjectModel() -> NSManagedObjectModel? {
        let url = Bundle(for: DatabaseContainer.self).url(forResource: "Database", withExtension: "momd")
        guard let modelUrl = url else {
            return nil
        }
        return NSManagedObjectModel(at: modelUrl)
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
        let databaseName = getDatabaseName()
        
        guard let model = getManagedObjectModel() else {
            return nil
        }
        
        let container = NSPersistentContainer(name: databaseName, managedObjectModel: model)
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
