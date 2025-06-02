//
//  TrackerStore.swift
//  Tracker
//
//  Created by Vladimir on 01.06.2025.
//

import CoreData

struct TrackerStoreUpdate {
    let insertedItemIndexPaths: Set<IndexPath>
    let insertedSections: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(with update: TrackerStoreUpdate)
}

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    
    // MARK: Internal Properties
    
    weak var delegate: TrackerStoreDelegate?
    
    var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerEntity>?
    private let transformer = TrackerEntityTransformer()
    
    private var insertedSections: IndexSet?
    private var insertedItemIndexPaths: Set<IndexPath>?
    
    // MARK: - Initializers
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Internal Properties
    
    func numberOfItemsInSection(_ section: Int) throws -> Int {
        guard let fetchedResultsController else {
            throw TrackerStoreError.fetchedResultsControllerIsNil
        }
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func sectionTitle(atSectionIndex index: Int) throws -> String {
        guard let fetchedResultsController else {
            throw TrackerStoreError.fetchedResultsControllerIsNil
        }
        guard let sectionInfo = fetchedResultsController.sections?[index] else {
            throw TrackerStoreError.unexpected(message: "TrackerStore.sectionTitle: Failed to get sections")
        }
        return sectionInfo.name
    }
    
    func tracker(at indexPath: IndexPath) throws -> Tracker {
        guard let fetchedResultsController else {
            throw TrackerStoreError.fetchedResultsControllerIsNil
        }
        let trackerEntity = fetchedResultsController.object(at: indexPath)
        return try transformer.tracker(from: trackerEntity)
    }
    
    func add(_ tracker: Tracker) throws {
        _ = try self.trackerEntity(from: tracker)
        try context.save()
    }
    
    func set(date: Date) throws {
        fetchedResultsController = try fetchedResultsController(for: date)
    }
    
    func isCompleted(tracker: Tracker, on date: Date) throws -> Bool {
        let trackerEntity = try trackerEntity(from: tracker)
        guard let records = trackerEntity.records as? Set<TrackerRecordEntity> else {
            return false
        }
        for recordEntity in records {
            guard let recordDate = recordEntity.date else {
                throw TrackerStoreError.recordPropertiesNotInitialized(forObjectID: recordEntity.objectID)
            }
            if Calendar.current.isDate(recordDate, inSameDayAs: date) { return true }
        }
        return false
    }
    
    // MARK: - Private Properties
    
    private func trackerEntity(from tracker: Tracker) throws -> TrackerEntity {
        let trackerEntity = TrackerEntity(context: context)
        trackerEntity.category = try categoryEntity(with: tracker.categoryID)
        trackerEntity.emoji = String(tracker.emoji)
        trackerEntity.id = tracker.id
        trackerEntity.rgbColor = RGBColorBoxedValue(value: tracker.color)
        trackerEntity.title = tracker.title
        switch tracker.schedule {
        case .irregular(let date):
            trackerEntity.isRegular = true
            trackerEntity.date = date
        case .regular(let weekdays):
            trackerEntity.isRegular = false
            trackerEntity.weekdaysMask = weekdaysMask(from: weekdays)
        }
        return trackerEntity
    }
    
    private func categoryEntity(with id: UUID) throws -> TrackerCategoryEntity {
        let request = TrackerCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        let requestResult = try context.fetch(request)
        if let trackerCategoryEntity = requestResult.first {
            return trackerCategoryEntity
        } else {
            throw TrackerStoreError.categoryNotFound(withID: id)
        }
    }
    
    private func fetchedResultsController(for date: Date, sortBy sort: NSSortDescriptor? = nil) throws -> NSFetchedResultsController<TrackerEntity> {
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerEntity.category?.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerEntity.title, ascending: true)
        ]
        fetchRequest.predicate = try fetchRequestPredicate(for: date)
        let resultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                          managedObjectContext: context,
                                                          sectionNameKeyPath: #keyPath(TrackerEntity.category.title),
                                                          cacheName: nil)
        resultController.delegate = self
        try resultController.performFetch()
        return  resultController
    }
    
    private func fetchRequestPredicate(for date: Date) throws -> NSCompoundPredicate {
        guard let weekday = Weekday.fromCalendarComponent(Calendar.current.component(.weekday, from: date)) else {
            throw TrackerStoreError.unexpected(message: "TrackerStore.fetchRequestPredicate: Failed to create weekday for date")
        }
        let weekdayBit = 1 << weekday.rawValue
        let regularPredicate = NSPredicate(format: "%K == YES AND (%K & %@ != 0)",
                                           #keyPath(TrackerEntity.isRegular),
                                           #keyPath(TrackerEntity.weekdaysMask),
                                           weekdayBit)
        let irregularPredicate = NSPredicate(format: "%K == NO AND %K == %@",
                                             #keyPath(TrackerEntity.isRegular),
                                             #keyPath(TrackerEntity.date),
                                             date as NSDate)
        return NSCompoundPredicate(orPredicateWithSubpredicates: [regularPredicate, irregularPredicate])
    }
    
    private func weekdaysMask(from weekdays: Set<Weekday>) -> Int16 {
        weekdays.reduce(0) { result, weekday in
            result | 1 << weekday.rawValue
        }
    }

}


// MARK: - TrackerStoreError
enum TrackerStoreError: Error {
    case categoryNotFound(withID: UUID)
    case trackerNotFound(withID: UUID)
    case trackerNotFound(atIndexPath: IndexPath)
    case trackerPropertiesNotInitialized(forObjectID: NSManagedObjectID)
    case recordPropertiesNotInitialized(forObjectID: NSManagedObjectID)
    case fetchedResultsControllerIsNil
    case unexpected(message: String)
}


// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedItemIndexPaths = Set()
        insertedSections = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let insertedItemIndexPaths, let insertedSections else {
            assertionFailure("TrackerStore.controllerDidChangeContent: Changed indices are nil on update")
            return
        }
        guard let delegate else {
            assertionFailure("TrackerStore.controllerDidChangeContent: delegate is nil")
            return
        }
        let update = TrackerStoreUpdate(insertedItemIndexPaths: insertedItemIndexPaths,
                                        insertedSections: insertedSections)
        delegate.didUpdate(with: update)
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange sectionInfo: any NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections?.insert(sectionIndex)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath else {
                assertionFailure("TrackerStore.controller: Failed to get newIndexPath for data change")
                return
            }
            insertedItemIndexPaths?.insert(newIndexPath)
        default:
            break
        }
    }
}
