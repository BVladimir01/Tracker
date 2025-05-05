//
//  UIColor+Color.swift
//  Tracker
//
//  Created by Vladimir on 05.05.2025.
//

import UIKit

extension UIColor {
    static func from(RGBColor color: RGBColor) -> UIColor {
        return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
    }
}
