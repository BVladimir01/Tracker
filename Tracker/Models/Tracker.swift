//
//  Tracker.swift
//  Tracker
//
//  Created by Vladimir on 05.05.2025.
//

import Foundation

struct Tracker: Identifiable, Equatable, Hashable {
    
    let id: UUID
    let title: String
    let color: RGBColor
    let emoji: Character
    let schedule: Schedule
    let categoryID: UUID
    let isPinned: Bool
    
    static func == (lhs: Tracker, rhs: Tracker) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
