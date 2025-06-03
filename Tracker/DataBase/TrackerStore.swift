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
    let removedItemIndexPaths: Set<IndexPath>
    let removedSections: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(with update: TrackerStoreUpdate)
}

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    
    // MARK: Internal Properties
    
    weak var delegate: TrackerStoreDelegate?
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerEntity>
    private let transformer = TrackerEntityTransformer()
    
    private var insertedSections: IndexSet?
    private var insertedItemIndexPaths: Set<IndexPath>?
    private var removedSections: IndexSet?
    private var removedItemIndexPaths: Set<IndexPath>?
    
    // MARK: - Initializers
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerEntity.category?.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerEntity.title, ascending: true)
        ]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                          managedObjectContext: context,
                                                          sectionNameKeyPath: #keyPath(TrackerEntity.category.title),
                                                          cacheName: nil)
        
        super.init()
        fetchedResultsController.delegate = self
        try fetchedResultsController.performFetch()
    }
    
    // MARK: - Internal Properties
    
    func numberOfItemsInSection(_ section: Int) throws -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func sectionTitle(atSectionIndex index: Int) throws -> String {
        guard let sectionInfo = fetchedResultsController.sections?[index] else {
            throw TrackerStoreError.unexpected(message: "TrackerStore.sectionTitle: Failed to get sections")
        }
        return sectionInfo.name
    }
    
    func tracker(at indexPath: IndexPath) throws -> Tracker {
        let trackerEntity = fetchedResultsController.object(at: indexPath)
        return try transformer.tracker(from: trackerEntity)
    }
    
    func add(_ tracker: Tracker) throws {
        _ = try self.trackerEntity(from: tracker)
        try context.save()
    }
    
    func set(date: Date) throws {
        fetchedResultsController.fetchRequest.predicate = try fetchRequestPredicate(for: date)
        try fetchedResultsController.performFetch()
    }
    
    func indexPath(for tracker: Tracker) throws -> IndexPath {
        let entity = try trackerEntity(for: tracker)
        guard let indexPath = fetchedResultsController.indexPath(forObject: entity) else {
            throw TrackerStoreError.unexpected(message: "TrackerStore.indexPath: Failed to find indexPath for tracker \(tracker)")
        }
        return indexPath
    }
    
    // MARK: - Private Properties
    
    private func trackerEntity(from tracker: Tracker) throws -> TrackerEntity {
        let trackerEntity = TrackerEntity(context: context)
        let colorEntity = ColorEntity(context: context)
        colorEntity.red = tracker.color.red
        colorEntity.blue = tracker.color.blue
        colorEntity.green = tracker.color.green
        colorEntity.alpha = tracker.color.alpha
        trackerEntity.color = colorEntity
        trackerEntity.category = try categoryEntity(with: tracker.categoryID)
        trackerEntity.emoji = String(tracker.emoji)
        trackerEntity.id = tracker.id
        trackerEntity.title = tracker.title
        switch tracker.schedule {
        case .irregular(let date):
            trackerEntity.isRegular = false
            trackerEntity.date = date
        case .regular(let weekdays):
            trackerEntity.isRegular = true
            trackerEntity.weekdaysMask = weekdaysMask(from: weekdays)
        }
        return trackerEntity
    }
    
    private func trackerEntity(for tracker: Tracker) throws -> TrackerEntity {
        let request = TrackerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as NSUUID)
        let entities = try context.fetch(request)
        guard entities.count <= 1 else {
            throw TrackerStoreError.unexpected(message: "TrackerStore.trackerEntity: number of entities for tracker \(tracker) is more than 1")
        }
        guard let entity = entities.first else {
            throw TrackerStoreError.unexpected(message: "TrackerStore.trackerEntity: no entities for tracker \(tracker)")
        }
        return entity
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
    
    private func fetchRequestPredicate(for date: Date) throws -> NSCompoundPredicate {
        guard let weekday = Weekday.fromCalendarComponent(Calendar.current.component(.weekday, from: date)) else {
            throw TrackerStoreError.unexpected(message: "TrackerStore.fetchRequestPredicate: Failed to create weekday for date")
        }
        let weekdayBit = 1 << weekday.rawValue
        let regularPredicate = NSPredicate(format: "%K == YES AND (%K & %@ != 0)",
                                           #keyPath(TrackerEntity.isRegular),
                                           #keyPath(TrackerEntity.weekdaysMask),
                                           weekdayBit as NSNumber)
        let dayStart = Calendar.current.startOfDay(for: date)
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
            throw TrackerStoreError.unexpected(message: "TrackerStore.fetchRequestPredicate: Failed to create nextDay date")
        }
        let nextDayStart = Calendar.current.startOfDay(for: nextDay)
        let irregularPredicate = NSPredicate(format: "%K == NO AND (%K >= %@ AND %K < %@)",
                                             #keyPath(TrackerEntity.isRegular),
                                             #keyPath(TrackerEntity.date),
                                             dayStart as NSDate,
                                             #keyPath(TrackerEntity.date),
                                             nextDayStart as NSDate)
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
    case delegateIsNil
}


// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedItemIndexPaths = Set()
        insertedSections = IndexSet()
        removedSections = IndexSet()
        removedItemIndexPaths = Set()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let insertedItemIndexPaths, let insertedSections, let removedSections, let removedItemIndexPaths else {
            assertionFailure("TrackerStore.controllerDidChangeContent: Changed indices are nil on update")
            return
        }
        guard let delegate else {
            assertionFailure("TrackerStore.controllerDidChangeContent: delegate is nil")
            return
        }
        let update = TrackerStoreUpdate(insertedItemIndexPaths: insertedItemIndexPaths,
                                        insertedSections: insertedSections,
                                        removedItemIndexPaths: removedItemIndexPaths,
                                        removedSections: removedSections)
        delegate.didUpdate(with: update)
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange sectionInfo: any NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections?.insert(sectionIndex)
        case .delete:
            removedSections?.insert(sectionIndex)
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
        case .delete:
            guard let indexPath else {
                assertionFailure("TrackerStore.controller: Failed to get indexPath for data change")
                return
            }
            removedItemIndexPaths?.insert(indexPath)
        default:
            break
        }
    }
}
