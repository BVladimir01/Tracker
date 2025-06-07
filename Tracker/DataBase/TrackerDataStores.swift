//
//  Stores.swift
//  Tracker
//
//  Created by Vladimir on 02.06.2025.
//


import CoreData


final class TrackerDataStores {
    let trackerStore: TrackerStore
    let categoryStore: CategoryStore
    let recordStore: RecordStore
    private let container: NSPersistentContainer
    
    init() throws {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        container.loadPersistentStores { description, error in
            if let error {
                assertionFailure("AppDelegate: \(error.localizedDescription)")
            }
        }
        let context = container.viewContext
        self.container = container
        self.trackerStore = try TrackerStore(context: context)
        self.categoryStore = try CategoryStore(context: context)
        self.recordStore = RecordStore(context: context)
    }
}


enum TrackerDataStoresError: Error {
    case trackerPropertiesNotInitialized(forObjectID: NSManagedObjectID)
    case categoryPropertiesNotInitialized(forObjectID: NSManagedObjectID)
    case unexpected(message: String)
}
