//
//  CategoryStoreStub.swift
//  Tracker
//
//  Created by Vladimir on 15.07.2025.
//

@testable import Tracker
import UIKit

final class CategoryStoreStub: CategoryStoreProtocol {
    
    var delegate: (any CategoryStoreDelegate)?
    var allTrackerCategories: [TrackerCategory] = []
    var numberOfRows: Int? { 0 }
    
    func add(_ category: TrackerCategory) throws { }
    
    func indexPath(for category: TrackerCategory) throws -> IndexPath? { nil }
    
    func trackerCategory(at indexPath: IndexPath) throws -> TrackerCategory {
        return TrackerCategory(id: UUID(), title: "Some Category")
    }
    
    func remove(_ category: TrackerCategory) throws { }
    
    func change(oldCategory: TrackerCategory, to newCategory: TrackerCategory) throws { }
    
}
