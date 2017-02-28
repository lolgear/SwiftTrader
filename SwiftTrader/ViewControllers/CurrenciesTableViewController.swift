//
//  CurrenciesTableViewController.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 25.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CurrenciesTableViewController: BaseTableViewController {
    var currencyDestination: String?
    var delegate: AddConversionBackProtocol?
    var cleanDataSource: [String]?
    var dataSourcePredicate: NSPredicate?
    var searchController: UISearchController?
}

//MARK: DataSource
extension CurrenciesTableViewController {
    func updateDataSource() {
        cleanDataSource = ServicesManager.manager.databaseService?.currencies()
    }
    var dataSource: [String]? {
        guard let predicate = dataSourcePredicate else {
            return cleanDataSource
        }
        return cleanDataSource?.filter({predicate.evaluate(with: $0)})
    }
}

//MARK: SearchViewController
extension CurrenciesTableViewController {
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        // bugs
        // thanks! http://stackoverflow.com/questions/32282401/attempting-to-load-the-view-of-a-view-controller-while-it-is-deallocating-uis
        if #available(iOS 9.0, *) {
            self.searchController?.loadViewIfNeeded()
        }
        tableView.tableHeaderView = searchController?.searchBar
    }
}

//MARK: Lifecycle
extension CurrenciesTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataSource()
    }
}

//MARK: Refresh
extension CurrenciesTableViewController {
    override func refresh(sender: UIRefreshControl?) {
        updateDataSource()
        sender?.endRefreshing()
    }
}

//MARK: FetchedResultsController
extension CurrenciesTableViewController {
    override func createFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        return ServicesManager.manager.databaseService?.fetchQuotes(delegate: self)
    }
}

//MARK: UITableViewDataSource
extension CurrenciesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // cell?
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrenciesCell", for: indexPath)
        if let source = dataSource {
            cell.textLabel?.text = indexPath.row > source.count ? source.last : source[indexPath.row]
        }
        return cell
    }
}

//MARK: UITableViewDelegate
extension CurrenciesTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let object = self.dataSource?[indexPath.row] {
            self.delegate?.set(currencyCode: object, for: currencyDestination)
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: NSFetchedResultsControllerDelegate
extension CurrenciesTableViewController {
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDataSource()
        super.controllerDidChangeContent(controller)
    }
}

//MARK: UISearchResultsUpdating
extension CurrenciesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            dataSourcePredicate = nil
            self.tableView.reloadData()
            return
        }
        
        dataSourcePredicate = text.isEmpty ? nil : NSPredicate(format: "SELF beginswith[c] %@", argumentArray: [text])
        
        self.tableView.reloadData()
    }
}
