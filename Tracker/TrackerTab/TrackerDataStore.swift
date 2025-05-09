//
//  TrackerDataSource.swift
//  Tracker
//
//  Created by Vladimir on 08.05.2025.
//

import Foundation
import UIKit


// MARK: - TrackerDataStore
class TrackerDataStore: TrackerDataSource {
    
    // MARK: - Internal Properties
    
    static let shared = TrackerDataStore()
    
    // MARK: - Private Properties
    
    private static let testTracker1 = Tracker(id: UUID(),
                                      title: "TrackerTitle",
                                              color: UIColor.ypColorSelection1.rgbColor ?? RGBColor(red: 1, green: 0, blue: 0),
                                      emoji: "😀",
                                      schedule: .regular(Set<Weekday>([.friday, .monday])))
    private static let testTracker2 = Tracker(id: UUID(),
                                      title: "TrackerTitle2",
                                              color: UIColor.ypColorSelection2.rgbColor ?? RGBColor(red: 0, green: 1, blue: 0),
                                      emoji: "🥹",
                                      schedule: .regular(Set<Weekday>([.friday, .monday])))
    private static let testTracker3 = Tracker(id: UUID(),
                                      title: "TrackerTitle3",
                                              color: UIColor.ypColorSelection3.rgbColor ?? RGBColor(red: 0, green: 0, blue: 1),
                                      emoji: "😎",
                                      schedule: .regular(Set<Weekday>([.friday, .monday])))
    
    private var trackerCategories: [TrackerCategory] = [
        TrackerCategory(title: "TrackerCategoryTitle1",
                        trackers: [testTracker1, testTracker2, testTracker3]),
        TrackerCategory(title: "TrackerCategoryTitle2",
                        trackers: [testTracker3, testTracker1, testTracker2]),
        TrackerCategory(title: "TrackerCategoryTitle3",
                        trackers: [testTracker2, testTracker3, testTracker1])
    ]
    
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackersDict: [Tracker: [Date]] = [:]
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Internal Methods
    
    func trackerCategories(on date: Date) -> [TrackerCategory] {
        var result: [TrackerCategory] = []
        for trackerCategory in trackerCategories {
            let categoryType = type(of: trackerCategory)
            let trackersToShow = trackerCategory.trackers.filter { shouldShow(tracker: $0, on: date) }
            if !trackersToShow.isEmpty {
                let newCategory = categoryType.init(title: trackerCategory.title,
                                                    trackers: trackersToShow)
                result.append(newCategory)
            }
        }
        return result
    }
    
    // MARK: - Private Methods
    
    private func shouldShow(tracker: Tracker, on date: Date) -> Bool {
        let calendar = Calendar.current
        guard let targetWeekday = Weekday(rawValue: calendar.component(.weekday, from: date)) else {
            assertionFailure("TrackerDataStore.shouldShow: Failed to create weekday from calendar")
            return false
        }
        switch tracker.schedule {
        case .regular(let trackerWeekdays):
            if trackerWeekdays.contains(targetWeekday) { return true }
        case .irregular(let trackerDate):
            if trackerDate == date { return true }
        }
        return false
    }
    
}
