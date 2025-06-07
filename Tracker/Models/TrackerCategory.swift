//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Vladimir on 05.05.2025.
//

import Foundation

struct TrackerCategory: Equatable {
    let id: UUID
    let title: String
    
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lhs.title == rhs.title
    }
}
