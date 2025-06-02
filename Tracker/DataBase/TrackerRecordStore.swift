//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Vladimir on 02.06.2025.
//

import CoreData


final class TrackerRecordStore {
    
    var context: NSManagedObjectContext
    var fetchedResultsController: NSFetchedResultsController<TrackerRecordEntity>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func add(_ record: TrackerRecord) throws {
        let recordEntity = TrackerRecordEntity(context: context)
        recordEntity.tracker = try trackerEntity(with: record.trackerId)
        recordEntity.date = record.date
        recordEntity.id = record.id
        context.insert(recordEntity)
        try context.save()
    }
    
    func remove(_ record: TrackerRecord) throws {
        let recordEntity = try trackerRecordEntity(with: record.id)
        context.delete(recordEntity)
        try context.save()
    }
    
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
    
    private func trackerEntity(with id: UUID) throws -> TrackerEntity {
        let request = TrackerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        let results = try context.fetch(request)
        if let trackerEntity = results.first {
            return trackerEntity
        } else {
            throw TrackerRecordStoreError.TrackerNotFound(id: id)
        }
    }
    
    private func trackerRecordEntity(with id: UUID) throws -> TrackerRecordEntity {
        let request = TrackerRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id as NSUUID)
        let results = try context.fetch(request)
        if let recordEntity = results.first {
            return recordEntity
        } else {
            throw TrackerRecordStoreError.TrackerRecordNotFound(id: id)
        }
    }
    
    enum TrackerRecordStoreError: Error {
        case unknown(message: String)
        case TrackerNotFound(id: UUID)
        case TrackerRecordNotFound(id: UUID)
    }
}
