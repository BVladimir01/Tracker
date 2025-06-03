//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Vladimir on 01.06.2025.
//


import CoreData


// MARK: - CategoryUpdate
struct CategoryUpdate {
    let insertedIndices: IndexSet
}


// MARK: - CategoryStoreDelegate
protocol CategoryStoreDelegate: AnyObject {
    func categoryStoreDidUpdate(with update: CategoryUpdate)
}


// MARK: - CategoryStore
final class CategoryStore: NSObject {
    
    // MARK: - Internal Properties
    
    weak var delegate: CategoryStoreDelegate?
    
    var numberOfRows: Int? {
        fetchedResultsController.sections?.first?.numberOfObjects
    }
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryEntity>
    
    private var insertedIndices: IndexSet?
    
    // MARK: - Initializers
    
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
    
    // MARK: - Internal Methods
    
    func add(_ category: TrackerCategory) throws {
        let categoryEntity = TrackerCategoryEntity(context: context)
        categoryEntity.title = category.title
        categoryEntity.id = category.id
        try context.save()
    }
    
    func indexPath(for category: TrackerCategory) throws -> IndexPath? {
        guard let entity = try fetchCategoryEntity(forCategoryWithID: category.id) else {
            return nil
        }
        return fetchedResultsController.indexPath(forObject: entity)
    }
    
    func trackerCategory(at indexPath: IndexPath) throws -> TrackerCategory {
        let categoryEntity = fetchedResultsController.object(at: indexPath)
        return try trackerCategory(from: categoryEntity)
    }
    
    // MARK: - Private Methods
    
    private func trackerCategory(from categoryEntity: TrackerCategoryEntity) throws -> TrackerCategory {
        guard let id = categoryEntity.id, let title = categoryEntity.title else {
            throw CategoryStoreError.propertyIsNil(ofObjectWithID: categoryEntity.objectID)
        }
        return TrackerCategory(id: id, title: title)
    }
    
    private func fetchCategoryEntity(forCategoryWithID id: UUID) throws -> TrackerCategoryEntity? {
        let request = TrackerCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        let entities = try context.fetch(request)
        if entities.count > 1 {
            throw CategoryStoreError.unexpected(message: "CategoryStore.fetchCategoryEntity: Several entities for category with id \(id)")
        }
        return entities.first
    }
    
}


// MARK: - CategoryStoreError
enum CategoryStoreError: Error {
    case propertyIsNil(ofObjectWithID: NSManagedObjectID)
    case categoryEntityDoesNotExist(forID: UUID)
    case unexpected(message: String)
}


// MARK: - NSFetchedResultsControllerDelegate
extension CategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndices = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let insertedIndices else {
            assertionFailure("CategoryStore.controllerDidChangeContent: changed indices are nil on update")
            return
        }
        let update = CategoryUpdate(insertedIndices: insertedIndices)
        delegate?.categoryStoreDidUpdate(with: update)
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath else {
                assertionFailure("CategoryStore.controller: Failed to unwrap newIndexPath for insertion")
                return
            }
            insertedIndices?.insert(newIndexPath.item)
        default:
            break
        }
    }
    
}
