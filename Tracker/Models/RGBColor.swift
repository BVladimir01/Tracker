//
//  RGBColor.swift
//  Tracker
//
//  Created by Vladimir on 05.05.2025.
//

import Foundation

struct RGBColor: Codable {
    
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
}


public final class RGBColorBoxedValue: BoxedValue<RGBColor> { }
