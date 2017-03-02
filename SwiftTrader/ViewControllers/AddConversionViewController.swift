//
//  AddConversionViewController.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 25.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit
protocol AddConversionBackProtocol {
    func set(currencyCode: String?, for destination: String?)
}
class AddConversionViewController: UIViewController {
    
    enum DestinationType: String{
        case from
        case to
        var segue: String {
            switch self {
            case .from: return "fromCodeSegue"
            case .to: return "toCodeSegue"
            }
        }
        init?(segue: String?) {
            guard let theSegue = segue else {
                return nil
            }
            
            switch theSegue {
            case DestinationType.from.segue: self = .from
            case DestinationType.to.segue: self = .to
            default: return nil
            }
        }
    }
    
    var conversion: ConversionModel = ConversionModel()
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var fromCurrencyButton: UIButton!
    @IBOutlet weak var toCurrencyButton: UIButton!

}

//MARK: Lifecycle
extension AddConversionViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        hideAllNotifications()
    }
}

//MARK: Seagues
extension AddConversionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CurrenciesTableViewController {
            controller.delegate = self
            controller.currencyDestination = DestinationType(segue: segue.identifier)?.rawValue
        }
        hideAllNotifications()
    }
}

//MARK: Actions
extension AddConversionViewController {
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let error = conversion.error {
            showNotificationError(error: error)
            return
        }
        
        guard let source = conversion.fromCode, let targetCode = conversion.toCode else {
            return
        }
        
        var errorOccured: Error?
        
        ServicesManager.manager.dataProviderService?.dataProvider.addConversion(source: source, target: targetCode, onError: {
            [unowned self]
            (error) in
            errorOccured = error
            DispatchQueue.main.async {
                self.showNotificationError(error: error)
            }
        }, completion: {
            [unowned self]
            (result, error) in
            DispatchQueue.main.async {
                self.showNotificationError(error: error)
            }
            
            if error == nil && errorOccured == nil {
                DispatchQueue.main.async {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
}

//MARK: AddConversionBackProtocol
extension AddConversionViewController: AddConversionBackProtocol {
    func set(currencyCode: String?, for destination: String?) {
        guard let code = currencyCode, let d = destination else {
            return
        }
        
        guard let type = DestinationType(rawValue: d) else {
            return
        }
        
        switch type {
        case .from:
            conversion.fromCode = code
            self.fromCurrencyButton.setTitle(conversion.fromCode, for: .normal)
        case .to:
            conversion.toCode = code
            self.toCurrencyButton.setTitle(conversion.toCode, for: .normal)
        }
    }
}
