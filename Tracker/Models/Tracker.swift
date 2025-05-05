//
//  Tracker.swift
//  Tracker
//
//  Created by Vladimir on 05.05.2025.
//

import Foundation

struct Tracker: Identifiable {
    
    let id: UUID
    let title: String
    let color: RGBColor
    let emoji: Character
    let schedule: Schedule
    
}
