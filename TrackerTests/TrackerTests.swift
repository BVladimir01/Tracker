//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Vladimir on 21.06.2025.
//

import SnapshotTesting
import XCTest

@testable import Tracker
typealias TrackerModel = Tracker

final class TrackerTests: XCTestCase {
    
    final class CategoryStoreStub: CategoryStoreProtocol {
        
        var delegate: (any CategoryStoreDelegate)?
        var allTrackerCategories: [TrackerCategory] = []
        var numberOfRows: Int? { 0 }
        
        func add(_ category: TrackerCategory) throws { }
        
        func indexPath(for category: TrackerCategory) throws -> IndexPath? { nil }
        
        func trackerCategory(at indexPath: IndexPath) throws -> TrackerCategory {
            return TrackerCategory(id: UUID(), title: "Some Category")
        }
        
        func remove(_ category: TrackerCategory) throws { }
        
        func change(oldCategory: TrackerCategory, to newCategory: TrackerCategory) throws { }
    }
    
    final class TrackerStoreMock: TrackerStoreProtocol {
        
        static let category = TrackerCategory(id: UUID(), title: "Some category")
        
        private let trackers: [TrackerModel] = [
            TrackerModel(id: UUID(),
                         title: "Tracker 1",
                         color: RGBColor(red: 1, green: 0, blue: 0),
                         emoji: "😎",
                         schedule: .regular([.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]), category: category , isPinned: false),
            TrackerModel(id: UUID(),
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
        
        func tracker(at indexPath: IndexPath) throws -> TrackerModel {
            trackers[indexPath.item]
        }
        
        func add(_ tracker: TrackerModel) throws { }
        
        func remove(_ tracker: TrackerModel) throws { }
        
        func change(oldTracker: Tracker, to newTracker: TrackerModel) throws { }
        
        func set(date: Date) throws { }
        
        func pinUnpinTracker(_ tracker: TrackerModel) throws { }
        
        }
    
    final class RecordStoreStub: RecordStoreProtocol {
        
        var delegate: (any RecordStoreDelegate)?
        
        func add(_ record: TrackerRecord) throws { }
        
        func removeRecord(from tracker: TrackerModel, on date: Date) throws { }
        
        func daysDone(of tracker: TrackerModel) throws -> Int { 0 }
        
        func isCompleted(tracker: TrackerModel, on date: Date) throws -> Bool { false }
        
    }

    func testTrackersListVC() {
        let trackerStore = TrackerStoreMock()
        let recordStore = RecordStoreStub()
        let categoryStore = CategoryStoreStub()
        let vc = TrackersListViewController(trackerStore: trackerStore,
                                            categoryStore: categoryStore,
                                            recordStore: recordStore)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), record: false)
        assertSnapshot(of: vc, as: .recursiveDescription(traits: .init(userInterfaceStyle: .light)), record: false)
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), record: false)
        assertSnapshot(of: vc, as: .recursiveDescription(traits: .init(userInterfaceStyle: .dark)), record: false)
    }

}
