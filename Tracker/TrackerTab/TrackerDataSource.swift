//
//  TrackerDataSource.swift
//  Tracker
//
//  Created by Vladimir on 08.05.2025.
//

import Foundation


protocol TrackerDataSource {
    var trackerCategories: [TrackerCategory] { get }
    func trackerCategories(on date: Date) -> [TrackerCategory]
    func daysDone(trackerID: UUID) -> Int
    func isCompleted(trackerID: UUID, on date: Date) -> Bool
    func removeRecord(for trackerID: UUID, on date: Date)
    func addRecord(for trackerID: UUID, on date: Date)
    func add(category: TrackerCategory)
    func add(tracker: Tracker, for category: TrackerCategory)
}

