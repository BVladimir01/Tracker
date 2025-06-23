//
//  TrackerStore.swift
//  Tracker
//
//  Created by Vladimir on 01.06.2025.
//

import CoreData

// MARK: - TrackerStoreDelegate
protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
}


// MARK: - TrackerStoreProtocol
protocol TrackerStoreProtocol: AnyObject {
    
    var numberOfSections: Int { get }
    var delegate: TrackerStoreDelegate? { get set }
    
    func numberOfItemsInSection(_ section: Int) -> Int?
    func sectionTitle(atSectionIndex index: Int) -> String?
    func tracker(at indexPath: IndexPath) throws -> Tracker
    func add(_ tracker: Tracker) throws
    func remove(_ tracker: Tracker) throws
    func change(oldTracker: Tracker, to newTracker: Tracker) throws
    func set(date: Date) throws
    func set(tracker: Tracker, pinned: Bool) throws 
    
}


// MARK: - TrackerStore
final class TrackerStore: NSObject, TrackerStoreProtocol {
    
    // MARK: Internal Properties
    
    weak var delegate: TrackerStoreDelegate?
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerEntity>
    private let transformer = TrackerEntityTransformer()
    
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
    
    func remove(_ tracker: Tracker) throws {
        guard let removedEntity = try fetchTrackerEntity(forTrackerWithID: tracker.id) else { return }
        context.delete(removedEntity)
        try context.save()
    }
    
    func change(oldTracker: Tracker, to newTracker: Tracker) throws {
        let changedEntity = try fetchTrackerEntity(forTrackerWithID: oldTracker.id)
        changedEntity?.category = try fetchCategoryEntity(forCategoryWithID: newTracker.category.id)
        if oldTracker.color != newTracker.color {
            let newColor = ColorEntity(context: context)
            newColor.alpha = newTracker.color.alpha
            newColor.red = newTracker.color.red
            newColor.green = newTracker.color.green
            newColor.blue = newTracker.color.blue
            changedEntity?.color = newColor
        }
        switch newTracker.schedule {
        case .regular(let weekdays):
            changedEntity?.weekdaysMask = weekdaysMask(from: weekdays)
            changedEntity?.isRegular = true
        case .irregular(let date):
            changedEntity?.date = date
            changedEntity?.isRegular = false
        }
        changedEntity?.emoji = String(newTracker.emoji)
        try context.save()
    }
    
    func set(date: Date) throws {
        fetchedResultsController.fetchRequest.predicate = try fetchRequestPredicate(for: date)
        try fetchedResultsController.performFetch()
    }
    
    func set(tracker: Tracker, pinned: Bool) throws {
        let entity = try fetchTrackerEntity(forTrackerWithID: tracker.id)
        entity?.isPinned = pinned
        try context.save()
    }
    
    func reloadData() throws {
        try fetchedResultsController.performFetch()
    }
    
    // MARK: - Private Methods
    
    private func createTrackerEntity(from tracker: Tracker) throws -> TrackerEntity {
        let trackerEntity = TrackerEntity(context: context)
        let colorEntity = ColorEntity(context: context)
        colorEntity.red = tracker.color.red
        colorEntity.blue = tracker.color.blue
        colorEntity.green = tracker.color.green
        colorEntity.alpha = tracker.color.alpha
        trackerEntity.color = colorEntity
        trackerEntity.category = try fetchCategoryEntity(forCategoryWithID: tracker.category.id)
        trackerEntity.emoji = String(tracker.emoji)
        trackerEntity.id = tracker.id
        trackerEntity.title = tracker.title
        trackerEntity.isPinned = tracker.isPinned
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
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let delegate else {
            assertionFailure("TrackerStore.controllerDidChangeContent: delegate is nil")
            return
        }
        delegate.trackerStoreDidUpdate()
    }
}
