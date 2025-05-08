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
    
    private(set) var trackerCategories: [TrackerCategory] = [
        TrackerCategory(title: "TrackerCategoryTitle1",
                        trackers: [testTracker1, testTracker2, testTracker3]),
        TrackerCategory(title: "TrackerCategoryTitle2",
                        trackers: [testTracker3, testTracker1, testTracker2]),
        TrackerCategory(title: "TrackerCategoryTitle3",
                        trackers: [testTracker2, testTracker3, testTracker1])
    ]
    
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
    
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackersDict: [Tracker: [Date]] = [:]
    
    // MARK: - Initializers
    
    private init() { }
    
}
