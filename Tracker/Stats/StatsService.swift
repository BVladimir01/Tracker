//
//  StatsService.swift
//  Tracker
//
//  Created by Vladimir on 21.06.2025.
//

import Foundation


final class StatsService {
    
    // MARK: - Internal Properties
    
    static let shared = StatsService()
    
    var totalTrackersDone: Int {
        get {
            storage.integer(forKey: totalTrackersDoneKey)
        }
        set {
            storage.set(newValue, forKey: totalTrackersDoneKey)
        }
    }
    
    // MARK: - Private Properties
    
    private let totalTrackersDoneKey = "totalTrackersDoneKey"
    private let storage = UserDefaults.standard
    
    
    // MARK: - Initializers
    
    private init() { }
    
}
