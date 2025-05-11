//
//  TrackerDataSource.swift
//  Tracker
//
//  Created by Vladimir on 08.05.2025.
//

import UIKit


// MARK: - TrackerDataStore
class TrackerDataStore: TrackerDataSource {
    
    // MARK: - Internal Properties
    
    static let shared = TrackerDataStore()
    
    private(set) var trackerCategories: [TrackerCategory] = [
        TrackerCategory(title: "TrackerCategoryTitle1",
                        trackers: [testTracker1, testTracker2, testTracker3]),
        TrackerCategory(title: "TrackerCategoryTitle2",
                        trackers: [testTracker3, testTracker1, testTracker2]),
        TrackerCategory(title: "TrackerCategoryTitle3",
                        trackers: [testTracker2, testTracker3, testTracker1]),
        TrackerCategory(title: "Irregular title", trackers: [irregularTracker])
    ]
    
    // MARK: - Private Properties
    
    private let calendar = Calendar.current
    
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
    
    private static let irregularTracker = Tracker(id: UUID(),
                                                  title: "irregularTracker",
                                                  color: UIColor.ypColorSelection4.rgbColor ?? RGBColor(red: 0.5, green: 0.5, blue: 0.5), 
                                                  emoji: "🥶",
                                                  schedule: .irregular(Date()))
    
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackersDict: [UUID: [Date]] = [:]
    
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
    
    func daysDone(of trackerID: UUID) -> Int {
        return completedTrackersDict[trackerID]?.count ?? 0
    }
    
    func isCompleted(trackerID id: UUID, on date: Date) -> Bool {
        guard let dates = completedTrackersDict[id] else { return false }
        for completedDate in dates {
            if calendar.isDate(completedDate, inSameDayAs: date) { return true }
        }
        return false
    }
    
    func addRecord(for trackerID: UUID, on date: Date) {
        // alter completedTrackers
        completedTrackers.append(TrackerRecord(id: trackerID, date: date))
        // alter completedTrackersDict
        if completedTrackersDict[trackerID] == nil {
            completedTrackersDict[trackerID] = [date]
        } else {
            completedTrackersDict[trackerID]?.append(date)
        }
    }
    
    func removeRecord(for trackerID: UUID, on date: Date) {
        // alter completedTrackers
        completedTrackers.removeAll(where: { record in
            record.id == trackerID && calendar.isDate(record.date, inSameDayAs: date)
        })
        // alter completedTrackersDict
        completedTrackersDict[trackerID]?.removeAll(where: { calendar.isDate($0, inSameDayAs: date) })
    }
    
    func add(category: TrackerCategory) {
        trackerCategories.append(category)
    }
    
    func add(tracker: Tracker, for category: TrackerCategory) {
        var newTrackers = category.trackers
        newTrackers.append(tracker)
        let newTrackerCategory = TrackerCategory(title: category.title, trackers: newTrackers)
        var newTrackerCategories: [TrackerCategory] = []
        for trackerCategory in trackerCategories {
            newTrackerCategories.append(trackerCategory == newTrackerCategory ? newTrackerCategory : trackerCategory)
        }
        trackerCategories = newTrackerCategories
    }
    
    // MARK: - Private Methods
    
    private func shouldShow(tracker: Tracker, on date: Date) -> Bool {
        guard let targetWeekday = Weekday.fromCalendarComponent(calendar.component(.weekday, from: date))else {
            assertionFailure("TrackerDataStore.shouldShow: Failed to create weekday from calendar")
            return false
        }
        switch tracker.schedule {
        case .regular(let trackerWeekdays):
            if trackerWeekdays.contains(targetWeekday) { return true }
        case .irregular(let trackerDate):
            if calendar.isDate(trackerDate, inSameDayAs: date) { return true }
        }
        return false
    }
    
}
