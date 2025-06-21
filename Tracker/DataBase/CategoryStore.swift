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


// MARK: CategoryStoreProtocol
protocol CategoryStoreProtocol: AnyObject {
    
    var delegate: CategoryStoreDelegate? { get set }
    var allTrackerCategories: [TrackerCategory] { get }
    var numberOfRows: Int? { get }
    
    func add(_ category: TrackerCategory) throws
    func indexPath(for category: TrackerCategory) throws -> IndexPath?
    func trackerCategory(at indexPath: IndexPath) throws -> TrackerCategory
    
}


// MARK: - CategoryStore
final class CategoryStore: NSObject, CategoryStoreProtocol {
    
    // MARK: - Internal Properties
    
    weak var delegate: CategoryStoreDelegate?
    
    var numberOfRows: Int? {
        fetchedResultsController.sections?.first?.numberOfObjects
    }
    
    var allTrackerCategories: [TrackerCategory] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap( {try? trackerCategory(from: $0)} )
    }
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<CategoryEntity>
    
    private var insertedIndices: IndexSet?
    
    // MARK: - Initializers
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        let request = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.title, ascending: true)]
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
        let categoryEntity = CategoryEntity(context: context)
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
    
    private func trackerCategory(from categoryEntity: CategoryEntity) throws -> TrackerCategory {
        guard let id = categoryEntity.id, let title = categoryEntity.title else {
            throw TrackerDataStoresError.categoryPropertiesNotInitialized(forObjectID: categoryEntity.objectID)
        }
        return TrackerCategory(id: id, title: title)
    }
    
    private func fetchCategoryEntity(forCategoryWithID id: UUID) throws -> CategoryEntity? {
        let request = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        let entities = try context.fetch(request)
        if entities.count > 1 {
            throw TrackerDataStoresError.unexpected(message: "CategoryStore.fetchCategoryEntity: Several entities for category with id \(id)")
        }
        return entities.first
    }
    
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
