//
//  RecordStore.swift
//  Tracker
//
//  Created by Vladimir on 02.06.2025.
//

import CoreData


// MARK: - RecordStoreDelegate
protocol RecordStoreDelegate: AnyObject {
    func recordStoreDidChangeRecordForTracker(_ tracker: Tracker)
}


// MARK: - RecordStore
final class RecordStore {
    
    // MARK: - Internal Properties
    
    weak var delegate: RecordStoreDelegate?
    
    // MARK: - Private Properties
    
    private var context: NSManagedObjectContext
    
    // MARK: - Initializers
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Internal Methods
    
    func add(_ record: TrackerRecord) throws {
        guard let delegate else {
            assertionFailure("RecordStore.add: delegate is nil")
            return
        }
        guard let trackerEntity = try fetchTrackerEntity(forTrackerWithID: record.trackerID) else {
            assertionFailure("RecordStore.add: failed to get entity for altered tracker (tracker id \(record.trackerID)")
            return
        }
        let recordEntity = RecordEntity(context: context)
        recordEntity.date = record.date
        recordEntity.trackerID = record.trackerID
        recordEntity.tracker = trackerEntity
        try context.save()
        let tracker = try TrackerEntityTransformer().tracker(from: trackerEntity)
        delegate.recordStoreDidChangeRecordForTracker(tracker)
    }
    
    func removeRecord(from tracker: Tracker, on date: Date) throws {
        guard let delegate else {
            assertionFailure("RecordStore.removeRecord: delegate is nil")
            return
        }
        guard let recordEntity = try fetchRecordEntity(forTrackerWithID: tracker.id, forDate: date) else {
            throw TrackerDataStoresError.unexpected(message: "RecordStore.RemoveRecord: tracker \(tracker.id) has no record for this day \(date)")
        }
        context.delete(recordEntity)
        try context.save()
        delegate.recordStoreDidChangeRecordForTracker(tracker)
    }
    
    func daysDone(of tracker: Tracker) throws -> Int {
        let request = RecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(RecordEntity.trackerID),
                                        tracker.id as NSUUID)
        return try context.fetch(request).count
    }
    
    func isCompleted(tracker: Tracker, on date: Date) throws -> Bool {
        return try fetchRecordEntity(forTrackerWithID: tracker.id, forDate: date) != nil
    }
    
    // MARK: - Private Methods
    
    private func fetchRequestPredicate(for date: Date) throws -> NSPredicate {
        let dayStart = Calendar.current.startOfDay(for: date)
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
            throw TrackerDataStoresError.unexpected(message: "RecordStore.fetchRequestPredicate: Failed to create nextDay date")
        }
        let dayEnd = Calendar.current.startOfDay(for: nextDay)
        return NSPredicate(format: "%K >= %@ AND %K < %@",
                           #keyPath(RecordEntity.date),
                           dayStart as NSDate,
                           #keyPath(RecordEntity.date),
                           dayEnd as NSDate)
    }
    
    private func fetchTrackerEntity(forTrackerWithID id: UUID) throws -> TrackerEntity? {
        let request = TrackerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        let entities = try context.fetch(request)
        if entities.count > 1 {
            throw TrackerDataStoresError.unexpected(message: "RecordStore.fetchTrackerEntity: tracker with id \(id) has more than one entity")
        }
        return entities.first
    }
    
    private func fetchRecordEntity(forTrackerWithID id: UUID, forDate date: Date) throws -> RecordEntity? {
        let request = RecordEntity.fetchRequest()
        let idPredicate = NSPredicate(format: "%K == %@",
                                      #keyPath(RecordEntity.trackerID),
                                      id as NSUUID)
        let dayPredicate = try fetchRequestPredicate(for: date)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate, dayPredicate])
        let recordEntities = try context.fetch(request)
        if recordEntities.count > 1 {
            throw TrackerDataStoresError.unexpected(message: "RecordStore.RemoveRecord: tracker with id \(id) has more than one record for the day \(date)")
        }
        return recordEntities.first
    }
    
}
