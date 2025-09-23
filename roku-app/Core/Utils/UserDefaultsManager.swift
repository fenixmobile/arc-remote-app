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
    private let hasSeenOnboardingPaywallKey = "hasSeenOnboardingPaywall"
    private let shouldSkipNextMainPaywallKey = "shouldSkipNextMainPaywall"
    
    private init() {}
    
    var hasCompletedOnboarding: Bool {
        get {
            return UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey)
        }
    }
    
    var hasSeenOnboardingPaywall: Bool {
        get {
            return UserDefaults.standard.bool(forKey: hasSeenOnboardingPaywallKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingPaywallKey)
        }
    }
    
    var shouldSkipNextMainPaywall: Bool {
        get {
            return UserDefaults.standard.bool(forKey: shouldSkipNextMainPaywallKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: shouldSkipNextMainPaywallKey)
        }
    }
    
    func markOnboardingCompleted() {
        hasCompletedOnboarding = true
    }
    
    func markOnboardingPaywallSeen() {
        hasSeenOnboardingPaywall = true
        shouldSkipNextMainPaywall = true
    }
    
    func markMainPaywallShown() {
        shouldSkipNextMainPaywall = false
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        hasSeenOnboardingPaywall = false
        shouldSkipNextMainPaywall = false
    }
}
