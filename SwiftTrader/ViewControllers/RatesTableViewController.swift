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
    lazy var conversionsResultsDelegate: NSFetchedResultsControllerDelegate = {
        let delegate = ConversionsFetchedResultsDelegate()
        delegate.ratesController = self
        return delegate
    }()
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
            DispatchQueue.main.async {
                self.showNotificationError(error: error)
                sender?.endRefreshing()
            }
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
        return ServicesManager.manager.databaseService?.fetchConversions(delegate: self.conversionsResultsDelegate)
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
                    DispatchQueue.main.async {
                        self.showNotificationError(error: error)
                    }
                })
            }
        }
    }
}

//MARK: NSFetchedResultsControllerDelegate
extension RatesTableViewController {
    class ConversionsFetchedResultsDelegate: NSObject, NSFetchedResultsControllerDelegate {
        weak var ratesController: RatesTableViewController?
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            ratesController?.tableView.beginUpdates()
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
            let indexSet = IndexSet(integer: sectionIndex)
            switch type {
            case .insert:
                ratesController?.tableView.insertSections(indexSet, with: .automatic)
            case .delete:
                ratesController?.tableView.deleteSections(indexSet, with: .automatic)
            default: break
                // nothing
            }
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            
            switch type {
            case .insert:
                ratesController?.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                ratesController?.tableView.deleteRows(at: [indexPath!], with: .automatic)
            case .update:
                ratesController?.configure(cell: ratesController?.tableView.cellForRow(at: indexPath!), at: indexPath!)
            case .move:
                ratesController?.tableView.deleteRows(at: [indexPath!], with: .automatic)
                ratesController?.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            ratesController?.tableView.endUpdates()
        }
    }
}

//MARK: Routing
extension RatesTableViewController {
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {}
}
