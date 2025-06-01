//
//  TrackerStore.swift
//  Tracker
//
//  Created by Vladimir on 01.06.2025.
//

import CoreData

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func add(_ item: Tracker) throws {
        let trackerEntity = try self.trackerEntity(from: item)
        try context.save()
    }
    
    private func trackerEntity(from tracker: Tracker) throws -> TrackerEntity {
        let trackerEntity = TrackerEntity(context: context)
        trackerEntity.category = try categoryEntity(for: tracker)
        trackerEntity.emoji = String(tracker.emoji)
        trackerEntity.id = tracker.id
        trackerEntity.rgbColor = RGBColorBoxedValue(value: tracker.color)
        trackerEntity.schedule = ScheduleBoxedValue(value: tracker.schedule)
        trackerEntity.title = tracker.title
        return trackerEntity
    }
    
    private func categoryEntity(for tracker: Tracker) throws -> TrackerCategoryEntity {
        let request = TrackerCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryEntity.title), tracker.category.title)
        let requestResult = try context.fetch(request)
        if let trackerCategoryEntity = requestResult.first {
            return trackerCategoryEntity
        } else {
            throw TrackerStoreError.CategoryFetchError(message: "TrackerStore.categoryEntity: failed to find category '\(tracker.category.title)'")
        }
    }
    
    
    enum TrackerStoreError: Error {
        case CategoryFetchError(message: String)
    }
}
