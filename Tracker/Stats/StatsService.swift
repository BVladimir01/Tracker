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
    static let statsDidChange = NSNotification.Name("statsDidChange")
    
    var totalTrackersDone: Int {
        get {
            storage.integer(forKey: totalTrackersDoneKey)
        }
        set {
            storage.set(newValue, forKey: totalTrackersDoneKey)
            notificationCenter.post(name: StatsService.statsDidChange, object: self)
        }
    }
    
    // MARK: - Private Properties
    
    private let totalTrackersDoneKey = "totalTrackersDoneKey"
    private let storage = UserDefaults.standard
    private let notificationCenter = NotificationCenter.default
    
    
    // MARK: - Initializers
    
    private init() { }
    
}
