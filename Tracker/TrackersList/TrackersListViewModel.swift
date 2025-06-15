//
//  TrackersListViewModel.swift
//  Tracker
//
//  Created by Vladimir on 15.06.2025.
//

import Foundation


// MARK: - TrackersListViewModel
final class TrackersListViewModel {
    
    // MARK: - Internal Properties
    
    var searchString: String? {
        didSet {
            updateDisplayedTrackers()
        }
    }
    var selectedFilter: TrackersListFilter = .all {
        didSet {
            updateDisplayedTrackers()
        }
    }
    var selectedDate: Date = Date() {
        didSet {
            try? trackerStore.set(date: selectedDate)
            updateDisplayedTrackers()
        }
    }
    
    var onTrackersChange: Binding<[[Tracker]]> = { _ in } {
        didSet {
            onTrackersChange(displayedTrackers)
        }
    }
    
    var numberOfSections: Int {
        displayedTrackers.count
    }
    
    // MARK: - Private Properties
    
    private let trackerStore: TrackerStore
    private let recordStore: RecordStore
    
    private var displayedTrackers: [[Tracker]] = [] {
        didSet {
            onTrackersChange(displayedTrackers)
        }
    }
    private var sectionTitles: [String] = []
    
    // MARK: - Initializers
    
    init(trackerStore: TrackerStore, recordStore: RecordStore) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        updateDisplayedTrackers()
    }
    
    // MARK: - Internal Methods
    
    func add(_ tracker: Tracker) {
        try? trackerStore.add(tracker)
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        trackerStore.numberOfItemsInSection(section) ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker {
        displayedTrackers[indexPath.section][indexPath.item]
    }
    
    func sectionTitle(at sectionIndex: Int) -> String {
        sectionTitles[sectionIndex]
    }

    // MARK: - Private Methods
    
    private func updateDisplayedTrackers() {
        var newlyDisplayedTrackers: [[Tracker]] = []
        var newSectionTitles: [String] = []
        for sectionIndex in 0..<trackerStore.numberOfSections {
            var sectionTrackers: [Tracker] = []
            for itemIndex in 0..<(trackerStore.numberOfItemsInSection(sectionIndex) ?? 0) {
                guard let tracker = try? trackerStore.tracker(at: IndexPath(item: itemIndex, section: sectionIndex)), let category = trackerStore.sectionTitle(atSectionIndex: sectionIndex), trackerFits(tracker: tracker, withCategoryTitle: category) else {
                    continue
                }
                sectionTrackers.append(tracker)
            }
            newlyDisplayedTrackers.append(sectionTrackers)
            newSectionTitles.append(trackerStore.sectionTitle(atSectionIndex: sectionIndex) ?? "")
        }
        displayedTrackers = newlyDisplayedTrackers
        sectionTitles = newSectionTitles
    }
    
    private func trackerFits(tracker: Tracker, withCategoryTitle category: String) -> Bool {
        trackerFitsFilter(tracker: tracker) && trackerFitsSearch(tracker: tracker) && categoryFitsSearch(categoryTitle: category)
    }
    
    private func trackerFitsFilter(tracker: Tracker) -> Bool {
        switch selectedFilter {
        case .all:
            return true
        case .today:
            return true
        case .completed:
            if let completed = try? recordStore.isCompleted(tracker: tracker, on: selectedDate) {
                return completed
            } else {
                return false
            }
        case .uncompleted:
            if let completed = try? recordStore.isCompleted(tracker: tracker, on: selectedDate) {
                return !completed
            } else {
                return true
            }
        }
    }
    
    private func trackerFitsSearch(tracker: Tracker) -> Bool{
        guard let searchString, !searchString.isEmpty else { return true }
        return tracker.title.lowercased().contains(searchString.lowercased())
    }
    
    private func categoryFitsSearch(categoryTitle: String) -> Bool {
        guard let searchString, !searchString.isEmpty else { return true }
        return categoryTitle.lowercased().contains(searchString.lowercased())
    }
    
}


// MARK: - TrackerStoreDelegate
extension TrackersListViewModel: TrackerStoreDelegate {
    func trackerStoreDidUpdate(with update: TrackerStoreUpdate) {
        updateDisplayedTrackers()
    }
}
