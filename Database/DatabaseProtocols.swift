//
//  DatabaseProtocols.swift
//  SwiftTrader
//
//  Created by Dmitry on 09.03.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import CoreData

protocol SourcesAndTargetsProtocol {
    static func find(source: String, target: String, context: NSManagedObjectContext) -> NSManagedObject?
}

extension SourcesAndTargetsProtocol {
    static func sourceAndTargetPredicate(source: String, target: String) -> NSPredicate {
        let sourcePredicate = NSPredicate(format: "sourceCode = %@", argumentArray: [source])
        let targetPredicate = NSPredicate(format: "targetCode = %@", argumentArray: [target])
        return NSCompoundPredicate(andPredicateWithSubpredicates: [sourcePredicate, targetPredicate])
    }
    
    static func validPair(source: String, target: String) throws -> Bool {
        guard source != target else {
            throw Errors.invalidPair(source, target).error
        }
        return true
    }
    
    static func notExistsPair(source: String, target: String, context: NSManagedObjectContext) throws -> Bool {
        guard find(source: source, target: target, context: context) == nil else {
            throw Errors.pairExists(source, target).error
        }
        return true
    }
}
