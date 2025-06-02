//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Vladimir on 01.06.2025.
//


import CoreData


final class TrackerCategoryStore {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryEntity>
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        self.fetchedResultsController = try initializeFetchedResultsController()
    }
    
    func add(_ category: TrackerCategory) throws {
        let categoryEntity = TrackerCategoryEntity(context: context)
        categoryEntity.title = category.title
        try context.save()
    }
    
    private func initializeFetchedResultsController() throws -> NSFetchedResultsController<TrackerCategoryEntity> {
        let request = TrackerCategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryEntity.title, ascending: true)]
        let resultsController =  NSFetchedResultsController(fetchRequest: request,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        try resultsController.performFetch()
        return resultsController
    }
}
