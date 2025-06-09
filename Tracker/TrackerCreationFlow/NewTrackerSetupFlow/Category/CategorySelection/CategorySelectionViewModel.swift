//
//  CategorySelectionViewModel.swift
//  Tracker
//
//  Created by Vladimir on 09.06.2025.
//


import UIKit

typealias Binding<T> = (T) -> ()

final class CategorySelectionViewModel {
    
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
    
    private let categoryStore: CategoryStore
    
    init(categoryStore: CategoryStore, selectedCategory: TrackerCategory?) {
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
    
    func addCategory(_ category: TrackerCategory) {
        do {
            try categoryStore.add(category)
        } catch {
            print("CategorySelectionViewModel.addCategory: error \(error)")
        }
    }
    
    func setSelectedCategory(to category: TrackerCategory) {
        selectedRow = categories.firstIndex(of: category)
    }
    
}



extension CategorySelectionViewModel: CategoryStoreDelegate {
    func categoryStoreDidUpdate(with update: CategoryUpdate) {
        categories = categoryStore.allTrackerCategories
    }
}
