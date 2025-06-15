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
    
    var numberOfSections: Int {
        displayedTrackers.count
    }
    
    var shouldDisplayStub: Bool {
        numberOfSections == 0
    }
    
    // MARK: - Private Properties
    
    private let trackerStore: TrackerStore
    private let recordStore: RecordStore
    
    private var displayedTrackers: [[Tracker]] = [] {
        didSet {
            onTrackersChange(displayedTrackers)
        }
    }
    private var onTrackersChange: Binding<[[Tracker]]> = { _ in } {
        didSet {
            onTrackersChange(displayedTrackers)
        }
    }
    private var sectionTitles: [String] = []
    
    // MARK: - Initializers
    
    init(trackerStore: TrackerStore, recordStore: RecordStore) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        trackerStore.delegate = self
        recordStore.delegate = self
    }
    
    // MARK: - Internal Methods
    
    func add(_ tracker: Tracker) {
        try? trackerStore.add(tracker)
    }
    
    func numberOfItemsInSection(_ sectionIndex: Int) -> Int? {
        guard (0..<numberOfSections).contains(sectionIndex) else {
            return nil
        }
        return displayedTrackers[sectionIndex].count
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard (0..<displayedTrackers.count).contains(indexPath.section), (0..<displayedTrackers[indexPath.section].count).contains(indexPath.item) else {
            return nil
        }
        return displayedTrackers[indexPath.section][indexPath.item]
    }
    
    func sectionTitle(at sectionIndex: Int) -> String? {
        guard (0..<sectionTitles.count).contains(sectionIndex) else {
            return nil
        }
        return sectionTitles[sectionIndex]
    }
    
    func trackerTapped(at indexPath: IndexPath) {
        guard let tracker = tracker(at: indexPath) else {
            assertionFailure("TrackersListViewModel.trackerTapped: failed to get tracker that was tapped")
            return
        }
        do {
            if try recordStore.isCompleted(tracker: tracker, on: selectedDate) {
                try recordStore.removeRecord(from: tracker, on: selectedDate)
            } else {
                try recordStore.add(TrackerRecord(trackerID: tracker.id, date: selectedDate))
            }
        } catch {
            assertionFailure("TrackersListViewModel.trackerTapped: error \(error)")
            return
        }
    }
    
    func daysDone(of tracker: Tracker) -> Int {
        return (try? recordStore.daysDone(of: tracker)) ?? 0
    }
    
    func isCompleted(tracker: Tracker) -> Bool {
        return (try? recordStore.isCompleted(tracker: tracker, on: selectedDate)) ?? false
    }

    func initialize(with closure: @escaping Binding<[[Tracker]]>) {
        onTrackersChange = closure
        updateDisplayedTrackers()
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
            return isCompleted(tracker: tracker)
        case .uncompleted:
            return !isCompleted(tracker: tracker)
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


// MARK: - RecordStoreDelegate
extension TrackersListViewModel: RecordStoreDelegate {
    func recordStoreDidChangeRecordForTracker(_ tracker: Tracker) {
        updateDisplayedTrackers()
    }
    
    
}
