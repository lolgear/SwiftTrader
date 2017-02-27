//
//  UIViewController+Extensions.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 25.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages
extension UIViewController {
    func showNotificationError(error: Error?) {
        guard let currentError = error else {
            return
        }
        let view = MessageView.viewFromNib(layout: .TabView)
        view.configureTheme(.error)
        view.button?.isHidden = true
        view.configureContent(title: "Error", body: currentError.localizedDescription, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        SwiftMessages.show(view: view)
        // show error :/
    }
    func hideAllNotifications() {
        SwiftMessages.hideAll()
    }
}
