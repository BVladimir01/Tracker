//
//  OnboardingStatus.swift
//  Tracker
//
//  Created by Vladimir on 09.06.2025.
//

import Foundation


final class OnboardingStatusStore {
    
    static let shared  = OnboardingStatusStore()
    
    private let storage = UserDefaults.standard
    private let onboardingIsPassedKey = "onboardingIsPassed"
    
    private init() { }
    
    var shouldShowOnboarding: Bool {
        !storage.bool(forKey: onboardingIsPassedKey)
    }
    
    func userDidPassOnboarding() {
        storage.set(true, forKey: onboardingIsPassedKey)
    }
}
