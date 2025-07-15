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
    
    var rgbColor: RGBColor? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return RGBColor(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
    }
    
    static let alwaysBlack = UIColor(dynamicProvider: { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .light:
            return .ypBlack
        case .dark:
            return .ypWhite
        default:
            return .ypBlack
        }
    })
    
    static let alwaysWhite = UIColor(dynamicProvider: { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return .ypWhite
            case .dark:
                return .ypBlack
            default:
                return .ypWhite
            }
        })
    
}
