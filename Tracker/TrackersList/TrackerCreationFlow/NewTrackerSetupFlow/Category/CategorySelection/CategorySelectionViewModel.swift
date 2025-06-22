//
//  CategorySelectionViewModel.swift
//  Tracker
//
//  Created by Vladimir on 09.06.2025.
//


import UIKit


// MARK: - CategorySelectionViewModel
final class CategorySelectionViewModel {
    
    // MARK: - Internal Properties
    
    var categories: [TrackerCategory] {
        didSet {
            onCategoriesChange?(categories)
        }
    }
    var onCategoriesChange: Binding<[TrackerCategory]>? {
        didSet {
            onCategoriesChange?(categories)
        }
    }
    var selectedRow: Int? {
        didSet {
            onSelectedRowChange?((oldValue, selectedRow))
        }
    }
    var onSelectedRowChange: Binding<(Int?, Int?)>? {
        didSet {
            onSelectedRowChange?((nil, selectedRow))
        }
    }
    var selectedCategory: TrackerCategory? {
        if let selectedRow {
            categories[selectedRow]
        } else {
            nil
        }
    }
    
    var numberOfRows: Int {
        categories.count
    }
    var shouldDisplayStub: Bool {
        categories.isEmpty
    }
    
    // MARK: - Private Properties
    
    private let categoryStore: CategoryStoreProtocol
    
    // MARK: - Initializers
    
    init(categoryStore: CategoryStoreProtocol, selectedCategory: TrackerCategory?) {
        self.categoryStore = categoryStore
        do {
            categories = try (0..<(categoryStore.numberOfRows ?? 0)).map { index in
                try categoryStore.trackerCategory(at: IndexPath(row: index, section: 0))
            }
        } catch {
            assertionFailure("CategorySelectionViewModel.init: error \(error)")
            categories = []
        }
        if let selectedCategory {
            selectedRow = categories.firstIndex(of: selectedCategory)
        }
        categoryStore.delegate = self
    }
    
    // MARK: - Internal Methods
    
    func add(_ category: TrackerCategory) {
        do {
            try categoryStore.add(category)
        } catch {
            assertionFailure("CategorySelectionViewModel.add: error \(error)")
        }
    }
    
    func remove(_ category: TrackerCategory) {
        do {
            let latestSelectedCategory = selectedCategory
            try categoryStore.remove(category)
            if let latestSelectedCategory {
                selectedRow = categories.firstIndex(of: latestSelectedCategory)
            }
        } catch {
            assertionFailure("CategorySelectionViewModel.remove: error \(error)")
        }
    }
    
    func change(oldCategory: TrackerCategory, to newCategory: TrackerCategory) {
        do {
            try categoryStore.change(oldCategory: oldCategory, to: newCategory)
        } catch {
            assertionFailure("CategorySelectionViewModel.change: error \(error)")
        }
    }
    
    func category(at indexPath: IndexPath) -> TrackerCategory? {
        guard (0..<categories.count).contains(indexPath.row) else {
            return nil
        }
        return categories[indexPath.row]
    }
    
    func setSelectedCategory(to category: TrackerCategory) {
        selectedRow = categories.firstIndex(of: category)
    }
    
}


// MARK: - CategoryStoreDelegate
extension CategorySelectionViewModel: CategoryStoreDelegate {
    func categoryStoreDidUpdate() {
        categories = categoryStore.allTrackerCategories
    }
}
