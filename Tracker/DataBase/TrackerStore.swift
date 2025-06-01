//
//  TrackerStore.swift
//  Tracker
//
//  Created by Vladimir on 01.06.2025.
//

import CoreData

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerEntity>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func add(_ tracker: Tracker) throws {
        let trackerEntity = try self.trackerEntity(from: tracker)
        try context.save()
    }
    
    private func trackerEntity(from tracker: Tracker) throws -> TrackerEntity {
        let trackerEntity = TrackerEntity(context: context)
        trackerEntity.category = try categoryEntity(for: tracker)
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
    
    private func categoryEntity(for tracker: Tracker) throws -> TrackerCategoryEntity {
        let request = TrackerCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryEntity.title), tracker.category.title)
        let requestResult = try context.fetch(request)
        if let trackerCategoryEntity = requestResult.first {
            return trackerCategoryEntity
        } else {
            throw TrackerStoreError.categoryNotFount(title: "\(tracker.category.title)")
        }
    }
    
    private func fetchedResultsController(for date: Date, sortBy sort: NSSortDescriptor? = nil) throws -> NSFetchedResultsController<TrackerEntity> {
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerEntity.title, ascending: true)]
        fetchRequest.predicate = try fetchRequestPredicate(for: date)
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: #keyPath(TrackerEntity.category),
                                          cacheName: nil)
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
    
    enum TrackerStoreError: Error {
        case categoryNotFount(title: String)
        case unexpected(message: String)
    }
}
