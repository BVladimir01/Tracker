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
    
    private let categoryStore: CategoryStore
    
    init(categoryStore: CategoryStore) {
        self.categoryStore = categoryStore
        do {
            categories = try (0..<(categoryStore.numberOfRows ?? 0)).map { index in
                try categoryStore.trackerCategory(at: IndexPath(row: index, section: 0))
            }
        } catch {
            assertionFailure("CategorySelectionViewModel.init: error \(error)")
            categories = []
        }
    }
    
}



extension CategorySelectionViewModel: CategoryStoreDelegate {
    func categoryStoreDidUpdate(with update: CategoryUpdate) {
        categories = categoryStore.allTrackerCategories
    }
}
