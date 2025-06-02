//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Vladimir on 02.06.2025.
//

import CoreData


// MARK: - TrackerRecordStore
final class TrackerRecordStore {
    
    // MARK: - Private Properties
    
    private var context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordEntity>?
    
    // MARK: - Initializers
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Internal Methods
    
    func add(_ record: TrackerRecord) throws {
        let recordEntity = TrackerRecordEntity(context: context)
        recordEntity.tracker = try trackerEntity(withID: record.trackerID)
        recordEntity.date = record.date
        recordEntity.id = record.id
        context.insert(recordEntity)
        try context.save()
    }
    
    func removeRecord(fromTrackerWithID trackerID: UUID, on date: Date) throws {
        let recordEntities = try trackerRecordEntities(on: date)
        for recordEntity in recordEntities {
            guard let trackerEntity = recordEntity.tracker else {
                throw TrackerRecordStoreError.recordPropertiesNotInitialized(forObjectID: recordEntity.objectID)
            }
            guard let id = trackerEntity.id else {
                throw TrackerRecordStoreError.trackerPropertiesNotInitialized(forObjectID: trackerEntity.objectID)
            }
            if trackerID == id {
                context.delete(recordEntity)
                try context.save()
            }
        }
        throw TrackerStoreError.unexpected(message: "TrackerRecordStore: failed to remove record")
    }
    
    func daysDone(of tracker: Tracker) throws -> Int {
        let request = TrackerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as NSUUID)
        let requestResult = try context.fetch(request)
        return requestResult.count
    }
    
    func isCompleted(trackerID: UUID, on date: Date) throws -> Bool {
        let request = TrackerEntity.fetchRequest()
        let idPredicate = NSPredicate(format: "id == %@",
                                        trackerID as NSUUID)
        let dayPredicate = try fetchRequestPredicate(for: date)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate, dayPredicate])
        request.predicate = compoundPredicate
        let requestResult = try context.fetch(request)
        return !requestResult.isEmpty
    }
    
    // MARK: - Private Methods
    
    private func fetchedResultsController(for date: Date?) throws -> NSFetchedResultsController<TrackerRecordEntity> {
        let request = TrackerRecordEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordEntity.date, ascending: true)]
        if let date {
            request.predicate = try fetchRequestPredicate(for: date)
        }
        let resultsController = NSFetchedResultsController(fetchRequest: request,
                                                           managedObjectContext: context,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        try resultsController.performFetch()
        return resultsController
    }
    
    private func fetchRequestPredicate(for date: Date) throws -> NSPredicate {
        let dayStart = Calendar.current.startOfDay(for: date)
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
            throw TrackerRecordStoreError.unknown(message: "TrackerRecordStore.fetchRequestPredicate: Failed to create nextDay date")
        }
        let dayEnd = Calendar.current.startOfDay(for: nextDay)
        return NSPredicate(format: "%K >= %@ AND %K < %@",
                           #keyPath(TrackerRecordEntity.date),
                           dayStart as NSDate,
                           #keyPath(TrackerRecordEntity.date),
                           dayEnd as NSDate)
    }
    
    private func trackerEntity(withID id: UUID) throws -> TrackerEntity {
        let request = TrackerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        let results = try context.fetch(request)
        if let trackerEntity = results.first {
            return trackerEntity
        } else {
            throw TrackerRecordStoreError.trackerNotFound(id: id)
        }
    }
    
    private func trackerEntities(on date: Date) throws -> [TrackerEntity] {
        let request = TrackerEntity.fetchRequest()
        request.predicate = try fetchRequestPredicate(for: date)
        return try context.fetch(request)
    }
    
    private func trackerRecordEntity(withID id: UUID) throws -> TrackerRecordEntity {
        let request = TrackerRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id as NSUUID)
        let recordEntities = try context.fetch(request)
        if let recordEntity = recordEntities.first {
            return recordEntity
        } else {
            throw TrackerRecordStoreError.trackerRecordNotFound(id: id)
        }
    }
    
    private func trackerRecordEntities(on date: Date) throws -> [TrackerRecordEntity] {
        let request = TrackerRecordEntity.fetchRequest()
        request.predicate = try fetchRequestPredicate(for: date)
        return try context.fetch(request)
    }
    
}

enum TrackerRecordStoreError: Error {
    case unknown(message: String)
    case trackerNotFound(id: UUID)
    case trackerRecordNotFound(id: UUID)
    case fetchedResultsControllerIsNil
    case trackerPropertiesNotInitialized(forObjectID: NSManagedObjectID)
    case recordPropertiesNotInitialized(forObjectID: NSManagedObjectID)
}
