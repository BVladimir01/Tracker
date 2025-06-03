//
//  Stores.swift
//  Tracker
//
//  Created by Vladimir on 02.06.2025.
//

final class TrackerDataStores {
    let trackerStore: TrackerStore
    let trackerCategoryStore: CategoryStore
    let trackerRecordStore: RecordStore
    
    init(trackerStore: TrackerStore, trackerCategoryStore: CategoryStore, trackerRecordStore: RecordStore) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
    }
}
