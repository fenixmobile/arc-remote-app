//
//  PaywallCacheManager.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
//

import Foundation
import FXFramework

class PaywallCacheManager {
    static let shared = PaywallCacheManager()
    
    private var paywalls: [String: FXPaywall] = [:]
    private var products: [String: [FXProduct]] = [:]
    private let queue = DispatchQueue(label: "paywall.cache", attributes: .concurrent)
    
    private init() {}
    
    func storePaywall(_ paywall: FXPaywall, for placementId: String) {
        queue.async(flags: .barrier) {
            self.paywalls[placementId] = paywall
        }
    }
    
    func storeProducts(_ products: [FXProduct], for paywallName: String) {
        queue.async(flags: .barrier) {
            self.products[paywallName] = products
        }
    }
    
    func getPaywall(for placementId: String) -> FXPaywall? {
        return queue.sync {
            return paywalls[placementId]
        }
    }
    
    func getProducts(for paywallName: String) -> [FXProduct]? {
        return queue.sync {
            return products[paywallName]
        }
    }
    
    func getPaywallData(for placementId: String) -> [String: Any]? {
        return queue.sync {
            return paywalls[placementId]?.remoteConfig
        }
    }
    
    func clearCache(for placementId: String) {
        queue.async(flags: .barrier) {
            self.paywalls.removeValue(forKey: placementId)
            self.products.removeValue(forKey: placementId)
        }
    }
    
    func clearAllCache() {
        queue.async(flags: .barrier) {
            self.paywalls.removeAll()
            self.products.removeAll()
        }
    }
}
