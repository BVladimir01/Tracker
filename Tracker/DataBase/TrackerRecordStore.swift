//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Vladimir on 02.06.2025.
//

import CoreData


// MARK: - TrackerRecordStoreDelegate
protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidChangeRecordForTracker(_ tracker: Tracker)
}


// MARK: - TrackerRecordStore
final class TrackerRecordStore {
    
    // MARK: - Internal Properties
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Private Properties
    
    private var context: NSManagedObjectContext
    
    // MARK: - Initializers
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Internal Methods
    
    func add(_ record: TrackerRecord) throws {
        guard let delegate else {
            throw TrackerRecordStoreError.delegateIsNil
        }
        let recordEntity = TrackerRecordEntity(context: context)
        recordEntity.tracker = try trackerEntity(withID: record.trackerID)
        recordEntity.date = record.date
        recordEntity.trackerID = record.trackerID
        recordEntity.id = record.id
        try context.save()
        let trackerEntity = try trackerEntity(withID: record.trackerID)
        let tracker = try TrackerEntityTransformer().tracker(from: trackerEntity)
        delegate.trackerRecordStoreDidChangeRecordForTracker(tracker)
    }
    
    func removeRecord(from tracker: Tracker, on date: Date) throws {
        guard let delegate else {
            throw TrackerRecordStoreError.delegateIsNil
        }
        guard let recordEntity = try trackerRecordEntity(for: tracker, on: date) else {
            throw TrackerRecordStoreError.unknown(message: "TrackerRecordStore.RemoveRecord: tracker \(tracker.id) has no record for this day \(date)")
        }
        context.delete(recordEntity)
        try context.save()
        delegate.trackerRecordStoreDidChangeRecordForTracker(tracker)
    }
    
    func daysDone(of tracker: Tracker) throws -> Int {
        let request = TrackerRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerRecordEntity.trackerID),
                                        tracker.id as NSUUID)
        let requestResult = try context.fetch(request)
        return requestResult.count
    }
    
    func isCompleted(tracker: Tracker, on date: Date) throws -> Bool {
        return try trackerRecordEntity(for: tracker, on: date) != nil
    }
    
    // MARK: - Private Methods
    
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
    
    private func trackerRecordEntity(for tracker: Tracker, on date: Date) throws -> TrackerRecordEntity? {
        let request = TrackerRecordEntity.fetchRequest()
        let idPredicate = NSPredicate(format: "%K == %@",
                                      #keyPath(TrackerRecordEntity.trackerID),
                                      tracker.id as NSUUID)
        let dayPredicate = try fetchRequestPredicate(for: date)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate, dayPredicate])
        let recordEntities = try context.fetch(request)
        if recordEntities.count > 1 {
            throw TrackerRecordStoreError.unknown(message: "TrackerRecordStore.RemoveRecord: tracker \(tracker.id) has more than one record for the day \(date)")
        }
        return recordEntities.first
    }
    
    private func trackerRecordEntities(on date: Date) throws -> [TrackerRecordEntity] {
        let request = TrackerRecordEntity.fetchRequest()
        request.predicate = try fetchRequestPredicate(for: date)
        return try context.fetch(request)
    }
    
    private func trackerRecord(fromEntity recordEntity: TrackerRecordEntity) throws -> TrackerRecord {
        guard let id = recordEntity.id, let trackerID = recordEntity.trackerID, let date = recordEntity.date else {
            throw TrackerRecordStoreError.recordPropertiesNotInitialized(forObjectID: recordEntity.objectID)
        }
        return TrackerRecord(id: id, trackerID: trackerID, date: date)
    }
    
}

enum TrackerRecordStoreError: Error {
    case unknown(message: String)
    case trackerNotFound(id: UUID)
    case trackerRecordNotFound(id: UUID)
    case fetchedResultsControllerIsNil
    case trackerPropertiesNotInitialized(forObjectID: NSManagedObjectID)
    case recordPropertiesNotInitialized(forObjectID: NSManagedObjectID)
    case delegateIsNil
}
