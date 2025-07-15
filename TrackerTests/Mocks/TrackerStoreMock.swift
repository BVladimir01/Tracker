//
//  TrackerStoreMock.swift
//  Tracker
//
//  Created by Vladimir on 15.07.2025.
//

@testable import Tracker
import UIKit

final class TrackerStoreMock: TrackerStoreProtocol {
    
    static let category = TrackerCategory(id: UUID(), title: "Some category")
    
    private let trackers: [Tracker] = [
        Tracker(id: UUID(),
                     title: "Tracker 1",
                     color: RGBColor(red: 1, green: 0, blue: 0),
                     emoji: "😎",
                     schedule: .regular([.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]), category: category , isPinned: false),
        Tracker(id: UUID(),
                     title: "Tracker 2",
                     color: RGBColor(red: 0, green: 0, blue: 1),
                     emoji: "🥶",
                     schedule: .regular([.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]), category: category , isPinned: true),
    ]
    
    var numberOfSections: Int { 1 }
    
    var delegate: (any TrackerStoreDelegate)?
    
    func numberOfItemsInSection(_ section: Int) -> Int? {
        trackers.count
    }
    
    func sectionTitle(atSectionIndex index: Int) -> String? {
        TrackerStoreMock.category.title
    }
    
    func tracker(at indexPath: IndexPath) throws -> Tracker {
        trackers[indexPath.item]
    }
    
    func add(_ tracker: Tracker) throws { }
    
    func remove(_ tracker: Tracker) throws { }
    
    func change(oldTracker: Tracker, to newTracker: Tracker) throws { }
    
    func set(date: Date) throws { }
    
    func set(tracker: Tracker, pinned: Bool) throws { }
    
}
