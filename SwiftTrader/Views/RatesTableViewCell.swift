//
//  RatesTableViewCell.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 25.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit
extension UITableViewCell {
    class func cellIdentifier() -> String {
        return self.description()
    }
}
class Formatters {
    class func timeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        return formatter
    }
    class func trendAndQuoteFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = "0"
        formatter.decimalSeparator = "."
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.positivePrefix = "+"
        formatter.negativePrefix = "-"
        return formatter
    }
    class func trendFormatter() -> NumberFormatter {
        let formatter = self.trendAndQuoteFormatter()
        formatter.maximumFractionDigits = 6
        return formatter
    }
    class func quoteFormatter() -> NumberFormatter {
        let formatter = self.trendAndQuoteFormatter()
        formatter.positivePrefix = ""
        formatter.negativePrefix = ""
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    class func colorForTrend(trend: Double) -> UIColor {
        if trend > 0 {
            return UIColor.green
        }
        if trend < 0 {
            return UIColor.red
        }
        return UIColor.darkGray
    }
    
    class func attributedTrend(trend: Double, formatted: String) -> NSAttributedString {
        return NSAttributedString(string: "(\(formatted))", attributes: [
            NSForegroundColorAttributeName : self.colorForTrend(trend: trend)
            ])
    }
    
    class func string(trend: NSAttributedString, quote: String) -> NSAttributedString {
        let result = NSMutableAttributedString(string: "\(quote) ")
        result.append(trend)
        return result
    }
}
class RatesTableViewCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var trendLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.darkGray
        timeLabel.numberOfLines = 0
        timeLabel.lineBreakMode = .byWordWrapping
    }
    func updateTime(time: Double) {
        timeLabel.text = Formatters.timeFormatter().string(from: Date(timeIntervalSince1970: time))
    }
    func updateTitle(one: String, two: String) {
        titleLabel.text = "\(one) - \(two)"
    }
    
    func update(trend: Double, quote: Double) {
        // set colour
        let quoteString = Formatters.quoteFormatter().string(from: NSNumber(value: quote))
        let trendString = Formatters.trendFormatter().string(from: NSNumber(value: trend))
//        // color if needed
//        self.trendLabel.text = [NSString labelTextWithTrend:trendString andQuote:quoteString];
        guard let q = quoteString, let t = trendString else {
            return
        }
        let finalTrend = Formatters.attributedTrend(trend: trend, formatted: t)
        let text = Formatters.string(trend: finalTrend, quote: q)
        trendLabel.attributedText = text
    }
}
