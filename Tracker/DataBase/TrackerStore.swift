//
//  TrackerStore.swift
//  Tracker
//
//  Created by Vladimir on 01.06.2025.
//

import CoreData


// MARK: - TrackerStoreUpdate
struct TrackerStoreUpdate {
    let insertedItemIndexPaths: Set<IndexPath>
    let insertedSections: IndexSet
    let removedItemIndexPaths: Set<IndexPath>
    let removedSections: IndexSet
}


// MARK: - TrackerStoreDelegate
protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate(with update: TrackerStoreUpdate)
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
    
    func numberOfItemsInSection(_ section: Int) -> Int? {
        return fetchedResultsController.sections?[section].numberOfObjects
    }
    
    func sectionTitle(atSectionIndex index: Int) -> String? {
        return fetchedResultsController.sections?[index].name
    }
    
    func tracker(at indexPath: IndexPath) throws -> Tracker {
        let trackerEntity = fetchedResultsController.object(at: indexPath)
        return try transformer.tracker(from: trackerEntity)
    }
    
    func add(_ tracker: Tracker) throws {
        _ = try self.createTrackerEntity(from: tracker)
        try context.save()
    }
    
    func set(date: Date) throws {
        fetchedResultsController.fetchRequest.predicate = try fetchRequestPredicate(for: date)
        try fetchedResultsController.performFetch()
    }
    
    func indexPath(for tracker: Tracker) throws -> IndexPath? {
        guard let entity = try fetchTrackerEntity(forTrackerWithID: tracker.id) else {
            return nil
        }
        return fetchedResultsController.indexPath(forObject: entity)
    }
    
    // MARK: - Private Properties
    
    private func createTrackerEntity(from tracker: Tracker) throws -> TrackerEntity {
        let trackerEntity = TrackerEntity(context: context)
        let colorEntity = ColorEntity(context: context)
        colorEntity.red = tracker.color.red
        colorEntity.blue = tracker.color.blue
        colorEntity.green = tracker.color.green
        colorEntity.alpha = tracker.color.alpha
        trackerEntity.color = colorEntity
        trackerEntity.category = try fetchCategoryEntity(forCategoryWithID: tracker.categoryID)
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
    
    private func fetchTrackerEntity(forTrackerWithID id: UUID) throws -> TrackerEntity? {
        let request = TrackerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        let entities = try context.fetch(request)
        if entities.count > 1 {
            throw TrackerDataStoresError.unexpected(message: "TrackerStore.fetchTrackerEntity: Several entities for tracker with id \(id)")
        }
        return entities.first
    }
    
    private func fetchCategoryEntity(forCategoryWithID id: UUID) throws -> CategoryEntity? {
        let request = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        let entities = try context.fetch(request)
        if entities.count > 1 {
            throw TrackerDataStoresError.unexpected(message: "TrackerStore.fetchCategoryEntity: Several entities for category with id \(id)")
        }
        return entities.first
    }
    
    private func fetchRequestPredicate(for date: Date) throws -> NSCompoundPredicate {
        guard let weekday = Weekday.fromCalendarComponent(Calendar.current.component(.weekday, from: date)) else {
            throw TrackerDataStoresError.unexpected(message: "TrackerStore.fetchRequestPredicate: Failed to create weekday for date")
        }
        let weekdayBit = 1 << weekday.rawValue
        let regularPredicate = NSPredicate(format: "%K == YES AND (%K & %@ != 0)",
                                           #keyPath(TrackerEntity.isRegular),
                                           #keyPath(TrackerEntity.weekdaysMask),
                                           weekdayBit as NSNumber)
        let dayStart = Calendar.current.startOfDay(for: date)
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
            throw TrackerDataStoresError.unexpected(message: "TrackerStore.fetchRequestPredicate: Failed to create nextDay date")
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
        delegate.trackerStoreDidUpdate(with: update)
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
