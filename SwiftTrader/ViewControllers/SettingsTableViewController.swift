//
//  SettingsTableViewController.swift
//  SwiftTrader
//
//  Created by Dmitry on 09.03.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit
protocol VariantsChosenProtocol: NSObjectProtocol {
    func didSelect(item: String?, atIndex index: Int, withIdentifier identifier: String?)
}
class DateComponentsFormatters {
    class func stringFromTimeInterval(interval: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day]
        formatter.zeroFormattingBehavior = .pad;
        let string = formatter.string(from: interval)
        return string
    }
}

// ViewModel
class SettingsDataSourceModel {
    let settings = ApplicationSettingsStorage()
    class Item {
        weak var model: SettingsDataSourceModel!
        var cell: UITableViewCell!
        var identifier: String?
        func update() {
            
        }
    }
    
    class VariantsItem: Item {
        var variants: [AnyObject]?
        var userVariants: [String]?
        enum Variants {
            case updateTime
            
            static func from(identifier: String?) -> Variants? {
                guard let id = identifier else {
                    return nil
                }
                
                switch id {
                case "identifier.updateTime": return .updateTime
                default: return nil
                }
            }
            
            func identifier() -> String? {
                switch self {
                case .updateTime: return "identifier.updateTime"
                }
            }
            static let updateTimeVariantsArray = [
                // 30 seconds
                30,
                // 1 minute
                60,
                // 5 minutes
                300,
                // 10 minutes
                600,
                // 30 minutes
                1800,
                // 1 hour
                3600,
                // 3 hours = 3600 * 3
                10800,
                // 6 hours = 3600 * 6
                21600,
                // 12 hours = 3600 * 12,
                43200,
                // 24 hours = 3600 * 24
                86400
            ]
            func variants() -> [AnyObject]? {
                switch self {
                case .updateTime: return Variants.updateTimeVariantsArray as [AnyObject]?
                }
            }
            
            func userVariants() -> [String]? {
                switch self {
                case .updateTime: return (variants() as? [Int])?.flatMap{ return DateComponentsFormatters.stringFromTimeInterval(interval: TimeInterval($0)) }
                }
            }
        }
        
        override func update() {
            if let variant = Variants.from(identifier: identifier) {
                switch variant {
                case .updateTime: cell.detailTextLabel?.text = DateComponentsFormatters.stringFromTimeInterval(interval: model.settings.updateTime)
                }
            }
        }
        
        class func create(variants: Variants, cell: UITableViewCell!) -> VariantsItem {
            let item = VariantsItem()
            item.variants = variants.variants()
            item.userVariants = variants.userVariants()
            item.identifier = variants.identifier()
            item.cell = cell
            return item
        }
    }
    
    private var items: [Item]?
    var newItems: [Item]? {
        get {
            return items
        }
        set {
            newValue?.forEach {$0.model = self}
            items = newValue
        }
    }
    
    func updateView() {
        items?.forEach { $0.update() }
    }
    
    func load() {
        settings.load()
        updateView()
    }
    
    func updateModel(index: Int, identifier: String?) {
        // switch over identifiers
        if let variant = SettingsDataSourceModel.VariantsItem.Variants.from(identifier: identifier), let value = variant.variants()?[index] as? Int {
            switch variant {
            case .updateTime: settings.updateTime = TimeInterval(value)
            }
        }
    }
    
    func save() {
        settings.save()
    }
}
class SettingsTableViewController: UITableViewController {
    let leftRightCellReuseIdentifier = "leftRightCellReuseIdentifier"
    let dataSourceModel = SettingsDataSourceModel()
    // cells
    var updateTimeTableViewCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSourceModel.load()
        setupViewModel()
    }
    
    func setupViewModel() {
        // Update Time
        let updateTimeCell = UITableViewCell(style: .value1, reuseIdentifier: leftRightCellReuseIdentifier)
        // add localization later?
        updateTimeCell.textLabel?.text = "Update Time"
        
        // at the end
        dataSourceModel.newItems = [SettingsDataSourceModel.VariantsItem.create(variants: .updateTime, cell: updateTimeCell)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSourceModel.updateView()
    }
}

//MARK: Actions
extension SettingsTableViewController {
    @IBAction func saveSettings() {
        dataSourceModel.save()
        self.performSegue(withIdentifier: "UnwindToRates", sender: self)
    }
}

//MARK: UITableViewDataSource
extension SettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceModel.newItems?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (dataSourceModel.newItems?.flatMap {$0.cell}[indexPath.row])!
    }
}

//MARK: UITableViewDelegate
extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = dataSourceModel.newItems?[indexPath.row] {
            if let variantItem = item as? SettingsDataSourceModel.VariantsItem {
                let controller = VariantsTableViewController.variants(items: variantItem.userVariants, variantsChosen: self, identifier: variantItem.identifier)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: VariantsChosenProtocol
extension SettingsTableViewController: VariantsChosenProtocol {
    func didSelect(item: String?, atIndex index: Int, withIdentifier identifier: String?) {
        dataSourceModel.updateModel(index: index, identifier: identifier)
    }
}

//MARK: Variants
extension SettingsTableViewController {
    class VariantsTableViewController: UITableViewController {
        private var variants: [String]!
        private weak var variantsChosen: VariantsChosenProtocol?
        private var identifier: String?
        class func variants(items: [String]?, variantsChosen: VariantsChosenProtocol?, identifier: String?) -> VariantsTableViewController {
            let controller = VariantsTableViewController(style: .grouped)
            controller.variants = items ?? []
            controller.variantsChosen = variantsChosen
            controller.identifier = identifier
            return controller
        }
        
        func setupTableView() {
            
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
        }
        
        //MARK: UITableViewDataSource
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return variants.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Default")
            cell.textLabel?.text = variants[indexPath.row]                        
            return cell
        }
        
        //MARK: UITableViewDelegate
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            variantsChosen?.didSelect(item: variants[indexPath.row], atIndex: indexPath.row, withIdentifier: identifier)
            tableView.deselectRow(at: indexPath, animated: true)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}
