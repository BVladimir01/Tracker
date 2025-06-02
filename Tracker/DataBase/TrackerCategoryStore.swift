//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Vladimir on 01.06.2025.
//


import CoreData


struct TrackerCategoryUpdate {
    let insertedIndices: IndexSet
}

protocol TrackerCategoryStoreDelegate {
    func didUpdate(with update: TrackerCategoryUpdate)
}

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryEntity>
    private let delegate:TrackerCategoryStoreDelegate
    
    private var insertedIndices: IndexSet?
    
    init(context: NSManagedObjectContext, delegate: TrackerCategoryStoreDelegate) throws {
        self.context = context
        self.delegate = delegate
        let request = TrackerCategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryEntity.title, ascending: true)]
        let resultsController =  NSFetchedResultsController(fetchRequest: request,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        try resultsController.performFetch()
        fetchedResultsController = resultsController
    }
    
    func add(_ category: TrackerCategory) throws {
        let categoryEntity = TrackerCategoryEntity(context: context)
        categoryEntity.title = category.title
        try context.save()
    }
    
}


extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndices = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let insertedIndices else {
            assertionFailure("TrackerCategoryStore.controllerDidChangeContent: changed indices are nil on update")
            return
        }
        let update = TrackerCategoryUpdate(insertedIndices: insertedIndices)
        delegate.didUpdate(with: update)
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath else {
                assertionFailure("TrackerCategoryStore.controller: Failed to unwrap newIndexPath for insertion")
                return
            }
            insertedIndices?.insert(newIndexPath.item)
        default:
            break
        }
    }
    
}
