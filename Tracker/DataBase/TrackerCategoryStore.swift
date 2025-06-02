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

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(with update: TrackerCategoryUpdate)
}

final class TrackerCategoryStore: NSObject {
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var numberOfRows: Int {
        fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryEntity>
    
    private var insertedIndices: IndexSet?
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        let request = TrackerCategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryEntity.title, ascending: true)]
        let resultsController =  NSFetchedResultsController(fetchRequest: request,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        fetchedResultsController = resultsController
        super.init()
        resultsController.delegate = self
        try resultsController.performFetch()
    }
    
    func add(_ category: TrackerCategory) throws {
        let categoryEntity = TrackerCategoryEntity(context: context)
        categoryEntity.title = category.title
        categoryEntity.id = category.id
        try context.save()
    }
    
    func indexPath(for category: TrackerCategory) throws -> IndexPath {
        let entity = try trackerCategoryEntity(from: category)
        guard let indexPath = fetchedResultsController.indexPath(forObject: entity) else {
            throw TrackerCategoryStoreError.categoryEntityDoesNotExist(forID: category.id)
        }
        return indexPath
    }
    
    func trackerCategory(at indexPath: IndexPath) throws -> TrackerCategory {
        let categoryEntity = fetchedResultsController.object(at: indexPath)
        return try trackerCategory(from: categoryEntity)
    }
    
    private func trackerCategory(from categoryEntity: TrackerCategoryEntity) throws -> TrackerCategory {
        guard let id = categoryEntity.id, let title = categoryEntity.title else {
            throw TrackerCategoryStoreError.propertyIsNil(ofObjectWithID: categoryEntity.objectID)
        }
        return TrackerCategory(id: id, title: title)
    }
    
    private func trackerCategoryEntity(from category: TrackerCategory) throws -> TrackerCategoryEntity {
        let request = TrackerCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", category.id as NSUUID)
        let categoryEntities = try context.fetch(request)
        guard let entity = categoryEntities.first else {
            throw TrackerCategoryStoreError.categoryEntityDoesNotExist(forID: category.id)
        }
        return entity
    }
    
}


enum TrackerCategoryStoreError: Error {
    case propertyIsNil(ofObjectWithID: NSManagedObjectID)
    case categoryEntityDoesNotExist(forID: UUID)
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
        delegate?.didUpdate(with: update)
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
