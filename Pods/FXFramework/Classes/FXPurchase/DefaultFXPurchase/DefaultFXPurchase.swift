//
//  DefaultFXPurchase.swift
//  FXPurchase
//
//  Created by Savaş Salihoğlu on 13.10.2023.
//

import Foundation

public class DefaultFXPurchase: FXPurchase {
    
    public var config: DefaultFXPurchaseConfig
    
    public init(config: DefaultFXPurchaseConfig) {
        self.config = config
    }
    
    public func getPaywall(by identifier: String,
                    completion: @escaping fxPaywallCompletion) {
        
    }
    
    public func getProducts(by paywall: FXPaywall?,
                     completion: @escaping fxProductsCompletion) {
        
    }
    
    public func startPurchase(with product: FXProduct,
                              completion: @escaping fxPurchaseResultCompletion) {
        
    }
    
    public func restore(completion: @escaping fxPurchaseResultCompletion) {
        
    }
    
    public func logShowPaywall(_ paywall: FXPaywall, _ completion: fxPurchaseErrorCompletion?) {
        
    }
    
    public func getPurchaseInfo(completion: @escaping fxPurchaseResultCompletion) {
        
    }
    
    public func setExternalUserId(_ externalUserId: String, _ completion: fxPurchaseErrorCompletion?) {
        
    }
}
