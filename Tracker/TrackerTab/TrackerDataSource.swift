//
//  TrackerDataSource.swift
//  Tracker
//
//  Created by Vladimir on 08.05.2025.
//

import Foundation


protocol TrackerDataSource {
    func trackerCategories(on date: Date) -> [TrackerCategory]
    func daysDone(tracker: Tracker) -> Int
}

