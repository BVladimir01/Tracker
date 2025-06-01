//
//  BoxedValue.swift
//  Tracker
//
//  Created by Vladimir on 01.06.2025.
//

import Foundation

class BoxedValue<T: Codable>: NSObject, Codable {
    let value: T
    init(value: T) {
        self.value = value
    }
}
