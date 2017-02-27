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
    
    enum destinationType: String{
        case from
        case to
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
            if let segueIdentifier = segue.identifier {
                switch segueIdentifier {
                case "fromCodeSegue": controller.currencyDestination = destinationType.from.rawValue
                case "toCodeSegue": controller.currencyDestination = destinationType.to.rawValue
                default: break
                }
            }
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
        
        ServicesManager.manager.dataProviderService?.dataProvider.addConversion(source: source, target: targetCode, onError: {
            [unowned self]
            (error) in
            self.showNotificationError(error: error)
        }, completion: { (result, error) in            
            self.showNotificationError(error: error)
            
            if error == nil {
                _ = self.navigationController?.popViewController(animated: true)
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
        
        if let type = destinationType(rawValue: d) {
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
}
