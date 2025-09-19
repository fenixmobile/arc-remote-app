//
//  UserDefaultsManager.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    private init() {}
    
    var hasCompletedOnboarding: Bool {
        get {
            return UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey)
        }
    }
    
    func markOnboardingCompleted() {
        hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}
