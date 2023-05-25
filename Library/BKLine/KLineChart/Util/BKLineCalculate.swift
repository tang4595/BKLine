//
//  Calculate.swift
//  KLine-Chart
//
//  Created by tang on 2022/11/8.
//  Copyright © 2022 chunjian wang. All rights reserved.
//

import UIKit

let formater = DateFormatter()

func clamp<T: Comparable>(value: T, min: T, max: T) -> T {
    if value < min {
        return min
    } else if value > max {
        return max
    } else {
        return value
    }
}

func calculateTextRect(text: String, font: UIFont) -> CGRect {
    let rect = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    return rect
}

func calculateDateText(timestamp: Int, dateFormat: String) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    formater.dateFormat = dateFormat
    return formater.string(from: date)
}

func volFormat(value: CGFloat) -> String {
    if value > 10000, value < 999_999 {
        let d = value / 1000
        return "\(String(format: "%.2f", d))K"
    } else if value > 1_000_000 {
        let d = value / 1_000_000
        return "\(String(format: "%.2f", d))M"
    }
    return String(format: "%.2f", value)
}
