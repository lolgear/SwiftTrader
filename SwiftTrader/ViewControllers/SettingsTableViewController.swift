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
protocol BackToParentProtocol: NSObjectProtocol {
    func didReturn(item: AnyObject?, at indexPath: IndexPath?, withIdentifier identifier: String?, returnValue value: AnyObject?)
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

protocol DataSourceModelEnums {
    static func from(identifier: String?) -> Self?
    func identifier() -> String?
}
// ViewModel


class SettingsDataSourceModel {
    
    //Items
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
        enum Variants: DataSourceModelEnums {
            case updateTime
            
            static func from(identifier: String?) -> Variants? {
                guard let id = identifier else {
                    return nil
                }
                
                switch id {
                case "identifier.variants.updateTime": return .updateTime
                default: return nil
                }
            }
            
            func identifier() -> String? {
                switch self {
                case .updateTime: return "identifier.variants.updateTime"
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
    
    class SwitchItem: Item {
        enum Switches: DataSourceModelEnums {
            static func from(identifier: String?) -> Switches? {
                guard let id = identifier else {
                    return nil
                }
                
                switch id {
                case "identifier.switches.backgroundFetch": return .backgroundFetch
                default: return nil
                }
            }
            
            func identifier() -> String? {
                switch self {
                case .backgroundFetch: return "identifier.switches.backgroundFetch"
                }
            }
            
            case backgroundFetch
            
            
        }
        
        func controlValueChanged(sender: UISwitch, forIdentifier identifier: String?) {
            if let theSwitch = Switches.from(identifier: identifier) {
                switch theSwitch {
                case .backgroundFetch: model.settings.backgroundFetch = sender.isOn
                }
            }
        }
        
        @objc func controlValueChanged(sender: UISwitch) {
            self.controlValueChanged(sender: sender, forIdentifier: self.identifier)
        }
        
        override func update() {
            if let theSwitch = Switches.from(identifier: identifier) {
                let switchControl = cell.accessoryView as? UISwitch
                switch theSwitch {
                case .backgroundFetch: switchControl?.isOn = model.settings.backgroundFetch
                }
            }
        }
        
        class func create(switches: Switches, cell: UITableViewCell!) -> SwitchItem {
            let item = SwitchItem()
            item.identifier = switches.identifier()
            item.cell = cell
            
            (item.cell.accessoryView as? UISwitch)?.addTarget(item, action: #selector(controlValueChanged(sender:)), for: .valueChanged)
            return item
        }
    }
    
    class InputItem: Item {
        enum Inputs: DataSourceModelEnums {
            static func from(identifier: String?) -> Inputs? {
                guard let id = identifier else {
                    return nil
                }
                
                switch id {
                case "identifier.inputs.networkAPIKey": return .networkAPIKey
                default: return nil
                }
            }
            
            func identifier() -> String? {
                switch self {
                case .networkAPIKey: return "identifier.inputs.networkAPIKey"
                }
            }
            
            case networkAPIKey
        }
        
        var label: String?
        var placeholder: String?
        var text: String? {
            guard let theInput = Inputs.from(identifier: self.identifier) else {
                return nil
            }
            switch theInput {
            case .networkAPIKey: return model.settings.networkAPIKey
            }
        }
        
        override func update() {
            let view = cell.detailTextLabel
            if let theInput = Inputs.from(identifier: identifier) {
                switch theInput {
                case .networkAPIKey: view?.text = model.settings.networkAPIKey
                    
                }
            }
        }
        
        class func create(inputs: Inputs, cell: UITableViewCell!, label: String?, placeholder: String?) -> InputItem {
            let item = InputItem()
            item.identifier = inputs.identifier()
            item.label = label
            item.placeholder = placeholder
            item.cell = cell
            return item
        }
    }
    
    //Application Settings
    let settings = ApplicationSettingsStorage()
    
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
    
    func updateModel(index: Int, identifier: String?, value: AnyObject?) {
        // switch over identifiers
        if let theVariant = VariantsItem.Variants.from(identifier: identifier) {
            guard let variantValue = theVariant.variants()?[index] else {
                return
            }
            switch theVariant {
            case .updateTime:
                if let theValue = variantValue as? Int {
                    settings.updateTime = TimeInterval(theValue)
                }
            }
            return
        }
        
        if let theInput = InputItem.Inputs.from(identifier: identifier) {
            switch theInput {
            case .networkAPIKey: 
                if let theValue = value as? String {
                    settings.networkAPIKey = theValue
                }
            }
            return
        }
    }
    
    func save() {        
        settings.save()
    }
}
class SettingsTableViewController: UITableViewController {
    enum cellReuseIdentifiers: String {
        case theLeftRight
        case theSwitch
        case theTextField
    }
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
        let updateTimeCell = UITableViewCell(style: .value1, reuseIdentifier: cellReuseIdentifiers.theLeftRight.rawValue)
        // add localization later?
        updateTimeCell.textLabel?.text = "Update Time"
        
        // Background Fetch
        let backgroundFetchEnabledCell = UITableViewCell(style: .default, reuseIdentifier: cellReuseIdentifiers.theSwitch.rawValue)
        backgroundFetchEnabledCell.textLabel?.text = "Background Fetch Enabled"
        backgroundFetchEnabledCell.accessoryView = UISwitch()
        
        // NetworkAPIKey
        let networkAPIKeyCell = UITableViewCell(style: .value1, reuseIdentifier: cellReuseIdentifiers.theTextField.rawValue)
        networkAPIKeyCell.textLabel?.text = "Network API Key"
        networkAPIKeyCell.accessoryView = UILabel()
        // at the end
        dataSourceModel.newItems = [SettingsDataSourceModel.VariantsItem.create(variants: .updateTime, cell: updateTimeCell), SettingsDataSourceModel.SwitchItem.create(switches: .backgroundFetch, cell: backgroundFetchEnabledCell), SettingsDataSourceModel.InputItem.create(inputs: .networkAPIKey, cell: networkAPIKeyCell, label: "API Key", placeholder: "Input API Key")
        ]
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
            
            if let inputItem = item as? SettingsDataSourceModel.InputItem {
                let controller = InputViewController.input(label: inputItem.label, placeholder: inputItem.placeholder, text: inputItem.text, identifier: inputItem.identifier, backTo: self)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: VariantsChosenProtocol
extension SettingsTableViewController: VariantsChosenProtocol {
    func didSelect(item: String?, atIndex index: Int, withIdentifier identifier: String?) {
        dataSourceModel.updateModel(index: index, identifier: identifier, value: nil)
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

//MARK: BackToParentProtocol
extension SettingsTableViewController: BackToParentProtocol {
    func didReturn(item: AnyObject?, at indexPath: IndexPath?, withIdentifier identifier: String?, returnValue value: AnyObject?) {
        guard let theIndexPath = indexPath else {
            return
        }
        
        dataSourceModel.updateModel(index: theIndexPath.row, identifier: identifier, value: value)
    }
}

//MARK: Input
extension SettingsTableViewController {
    class InputViewController: UITableViewController {
        private let textFieldStartTag = 100
        private var label: String?
        private var placeholder: String?
        private var text: String?
        private var identifier: String?
        private var backTo: BackToParentProtocol?
        
        private var cells: [UITableViewCell]!
        private let cellReuseIdentifier = "cellReuseIdentifier"
        
        class func input(label: String?, placeholder: String?, text: String?, identifier: String?, backTo delegate:BackToParentProtocol?) -> InputViewController {
            let controller = InputViewController(style: .grouped)
            controller.label = label
            controller.placeholder = placeholder
            controller.text = text
            controller.identifier = identifier
            controller.backTo = delegate
            return controller
        }
        
        func setupController() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            self.title = label
        }
        
        func setupCells() {
            let cell = UITableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
            var insets = UIEdgeInsets()
            insets.left = 8
            insets.right = insets.left
            let textField = UITextField(frame: CGRect(x: insets.left, y: 0, width: cell.contentView.frame.width - (insets.left + insets.right), height: cell.contentView.frame.height))
            textField.placeholder = placeholder
            textField.text = text
            textField.tag = textFieldStartTag
            // cheats :3
            cell.contentView.addSubview(textField)
            cells = [cell]
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.setupController()
            self.setupCells()
        }
        
        //MARK: Actions
        @objc func doneButtonPressed() {
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = cells[indexPath.row]
            let textField = cell.viewWithTag(textFieldStartTag) as? UITextField
            let text = textField?.text
            backTo?.didReturn(item: nil, at: indexPath, withIdentifier: identifier, returnValue: text as AnyObject)
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        //MARK: UITableViewDataSource
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return cells.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return cells[indexPath.row]
        }
        
        //MARK: UITableViewDelegate
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
