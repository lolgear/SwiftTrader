//
//  BaseTableViewController.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 25.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class BaseTableViewController: UITableViewController {
    
    //MARK: Refresh
    var refreshControlItem: UIRefreshControl?
    func createRefreshControl() -> UIRefreshControl {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return control
    }
    
    func refresh(sender: UIRefreshControl?) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUIElements()
    }
    
    func setupUIElements() {
        if refreshControlItem == nil {
            refreshControlItem = createRefreshControl()
            view.addSubview(refreshControlItem!)
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = {
        return self.createFetchedResultsController()
    }()
}

//MARK: FetchedResultsController
extension BaseTableViewController {
    func createFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        return nil
    }
}

extension BaseTableViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}

extension BaseTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
}

extension BaseTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
