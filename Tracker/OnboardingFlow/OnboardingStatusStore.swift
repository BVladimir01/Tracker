//
//  OnboardingStatus.swift
//  Tracker
//
//  Created by Vladimir on 09.06.2025.
//

import Foundation


// MARK: - OnboardingStatusStore
final class OnboardingStatusStore {
    
    // MARK: - Internal Properties
    
    var shouldShowOnboarding: Bool {
        !storage.bool(forKey: onboardingIsPassedKey)
    }
    
    // MARK: - Private Properties
    
    static let shared  = OnboardingStatusStore()
    
    private let storage = UserDefaults.standard
    private let onboardingIsPassedKey = "onboardingIsPassed"
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Internal Methods
    
    func userDidPassOnboarding() {
        storage.set(true, forKey: onboardingIsPassedKey)
    }
    
}
