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

class DatabaseService: BaseService {
    var baseCode: String {
        get {
            return DatabaseSettings.baseCode
        }
        set {
            DatabaseSettings.baseCode = newValue
        }
    }
    
    var container: DatabaseContainerProtocol?
    var accidentError: Error?
    var supplement: DatabaseSupplement?
    lazy var context: NSManagedObjectContext? = {
        return self.viewContext()
    }()
}

//MARK: Context and Stack.
extension DatabaseService {
    func checkStack() -> Bool {
        return container != nil && accidentError == nil && context != nil
    }
    func viewContext() -> NSManagedObjectContext? {
        return container?.viewContext()
    }
}

//MARK: DatabaseSupplement
extension DatabaseService {
    func fetchConversions(delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<NSFetchRequestResult>? {
        guard checkStack(), let context = context else {
            return nil
        }
        return supplement?.fetchConversions(delegate: delegate, context: context)
    }
    func fetchQuotes(delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<NSFetchRequestResult>? {
        guard checkStack(), let context = context else {
            return nil
        }
        return supplement?.fetchQuotes(delegate: delegate, context: context)
    }
    func currencies() -> [String] {
        guard checkStack(), let context = context, let theSupplement = supplement else {
            return []
        }
        return theSupplement.currencies(context: context)
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
    override func setup() {
        container = DatabaseContainer.container()
        container?.setupStack()
        supplement = DatabaseSupplement()
    }
    
    override func tearDown() {
        do {
            try container?.viewContext()?.save()
            container?.cleanupStack()
        }
        catch let error {
            LoggingService.logError("\(self) \(#function) error: \(error)")
        }
//        MagicalRecord.cleanUp()
    }
}
