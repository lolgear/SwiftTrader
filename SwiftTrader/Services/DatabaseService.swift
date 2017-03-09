//
//  DatabaseService.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import Database
import CoreData
//import MagicalRecord

class DatabaseService: BaseService {
    var baseCode: String {
        get {
            return DatabaseSettings.baseCode
        }
        set {
            DatabaseSettings.baseCode = newValue
        }
    }
//    var stack: MagicalRecordStack?
    var container: DatabaseContainerProtocol?
    var accidentError: Error?
    func checkStack() -> Bool {
        return container != nil && accidentError == nil && context != nil
    }
    func viewContext() -> NSManagedObjectContext? {
        return container?.viewContext()
    }
    lazy var context: NSManagedObjectContext? = {
        return self.viewContext()
    }()
}

//MARK: DatabaseSupplement
extension DatabaseService {
    func fetchConversions(delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<NSFetchRequestResult>? {
        guard checkStack(), let context = context else {
            return nil
        }
        
        return DatabaseSupplement.fetchConversions(delegate: delegate, context: context)
    }
    func fetchQuotes(delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<NSFetchRequestResult>? {
        guard checkStack(), let context = context else {
            return nil
        }
        return DatabaseSupplement.fetchQuotes(delegate: delegate, context: context)
    }
    func currencies() -> [String] {
        guard checkStack(), let context = context else {
            return []
        }
        return DatabaseSupplement.currencies(context: context)
    }
    func save(block:@escaping ((NSManagedObjectContext?) -> Void), completion: ((Bool, Error?) -> Void)?) {
        guard checkStack() else {
            return
        }
        container?.save(block: block, completion: completion)
    }
}

//MARK: Conversion manipulation
extension DatabaseService {
    func delete(source: String, target: String, context:NSManagedObjectContext) throws {
        guard checkStack() else {
            return // throw error?
        }
        try Conversion.delete(source: source, target: target, context: context)
    }
    func insert(source: String, target: String, context: NSManagedObjectContext) throws {
        guard checkStack() else {
            return
        }
        try Conversion.insert(source: source, target: target, context: context)
    }
}

//MARK: Quote manipulation
extension DatabaseService {
    func upsert(source: String, target: String, quote: Double, timestamp: Double, context: NSManagedObjectContext) {
        guard checkStack() else {
            return
        }
        Quote.upsert(source: source, target: target, quote: quote, timestamp: timestamp, context: context)
    }
}

extension DatabaseService {
    override var health: Bool {
        return !baseCode.isEmpty && checkStack()
    }
}

extension DatabaseService {
    func mr_setup() {
        // fucking magical record
        
        // pass scheme name to it.
//        guard let stack = MagicalRecord.setupAutoMigratingStack() else {
//            return
//        }
//
//        stack.model = NSManagedObjectModel(at: databaseUrl)
//        stack.coordinator = stack.createCoordinator(options: nil)
//        self.stack = stack
//        MagicalRecordStack.setDefault(stack)
    }
    
    override func setup() {
        container = DatabaseContainer.container()
        container?.setup()
    }
    
    override func tearDown() {
        do {
            try container?.viewContext()?.save()
        }
        catch let error {
            LoggingService.logError("\(self) \(#function) error: \(error)")
        }
//        MagicalRecord.cleanUp()
    }
}
