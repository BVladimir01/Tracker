//
//  Stores.swift
//  Tracker
//
//  Created by Vladimir on 02.06.2025.
//

final class TrackerDataStores {
    let trackerStore: TrackerStore
    let trackerCategoryStore: TrackerCategoryStore
    let trackerRecordStore: TrackerRecordStore
    
    init(trackerStore: TrackerStore, trackerCategoryStore: TrackerCategoryStore, trackerRecordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
    }
}
