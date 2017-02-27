//
//  RatesTableViewController.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 25.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Database

class RatesTableViewController : BaseTableViewController {
    var listener: NSFetchedResultsController<NSFetchRequestResult>?
}

//MARK: Listener
extension RatesTableViewController {
    func createListener() -> NSFetchedResultsController<NSFetchRequestResult>? {
        return ServicesManager.manager.databaseService?.fetchQuotes(delegate: self)
    }
    func setupListener() {
        if listener == nil {
            listener = createListener()
        }
    }
}

//MARK: Refresh
extension RatesTableViewController {
    override func refresh(sender: UIRefreshControl?) {
        let service = ServicesManager.manager.dataProviderService
        sender?.beginRefreshing()
        service?.dataProvider.updateQuotes(completion: {
            [unowned self]
            (result, error) in
            self.showNotificationError(error: error)
            // stop spinning refresh?
            sender?.endRefreshing()
        })
    }
}

//MARK: Lifecycle
extension RatesTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "RatesTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: RatesTableViewCell.cellIdentifier())
        self.setupListener()
    }
}

//MARK: FetchedResultsController
extension RatesTableViewController {
    override func createFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        return ServicesManager.manager.databaseService?.fetchConversions(delegate: self)
    }
}

//MARK: UITableViewDataSource
extension RatesTableViewController {
    func configure(cell: UITableViewCell?, at indexPath: IndexPath) {
        guard let currentCell = cell as? RatesTableViewCell else {
            return
        }
        
        if let object = self.fetchedResultsController?.object(at: indexPath) as? Conversion {
            // find quote by conversion.
            let trend: Double = object.quote?.trend ?? 0
            let quote: Double = object.quote?.quote ?? 0
            let source: String = object.quote?.sourceCode ?? ""
            let target: String = object.quote?.targetCode ?? ""
            let time: Double = object.quote?.timestamp ?? 0
            currentCell.update(trend: trend, quote: quote)
            currentCell.updateTitle(one: source, two: target)
            currentCell.updateTime(time: time)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RatesTableViewCell.cellIdentifier(), for: indexPath)
        self.configure(cell: cell, at: indexPath)
        return cell
    }
}

//MARK: UITableViewDelegate
extension RatesTableViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete item
            let service = ServicesManager.manager.dataProviderService
            
            if let object = self.fetchedResultsController?.object(at: indexPath) as? Conversion {
                service?.dataProvider.removeConversion(source: object.sourceCode!, target: object.targetCode!, onError: {
                    [unowned self]
                    error in
                    self.showNotificationError(error: error)
                    return
                })
            }
        }
    }
}

//MARK: NSFetchedResultsControllerDelegate
extension RatesTableViewController {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.beginUpdates()
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        let indexSet = IndexSet(integer: sectionIndex)
//        switch type {
//        case .insert:
//            tableView.insertSections(indexSet, with: .fade)
//        case .delete:
//            tableView.deleteSections(indexSet, with: .fade)
//        default: break
//            // nothing
//        }
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        
//        switch type {
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//        case .update:
//            self.configure(cell: tableView.cellForRow(at: indexPath!), at: indexPath!)
//        case .move:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//        }
//    }
//    
//    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.endUpdates()
//    }
}
