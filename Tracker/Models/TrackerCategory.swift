//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Vladimir on 05.05.2025.
//

struct TrackerCategory: Equatable {
    let title: String
    
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lhs.title == rhs.title
    }
}
