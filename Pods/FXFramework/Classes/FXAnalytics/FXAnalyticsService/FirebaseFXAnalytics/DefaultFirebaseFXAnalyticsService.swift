//
//  FirebaseFXAnalytics.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 17.10.2023.
//

import Foundation
import FirebaseCore
import FirebaseAnalytics


public class DefaultFirebaseFXAnalyticsService: FirebaseFXAnalyticsService {
    
    public var firebaseInstanceId: String? {
        return Analytics.appInstanceID()
    }
    
    let config: FirebaseFXAnalyticsServiceConfig
    
    public init(config: FirebaseFXAnalyticsServiceConfig) {
        self.config = config
        FirebaseApp.configure()
    }
    
    public func logEvent(_ event: String, properties: [String : Any]?) {
        
        guard config.eventTypes.contains(.default) else { return }
        
        Analytics.logEvent(event, parameters: properties)
    }
    
    public func setProperty(_ property: String, value: String) {
        
        guard config.eventTypes.contains(.property) else { return }
        
    }
    
    public func revenueEvent(_ revenueEvent: FXRevenueEvent) {
        
        guard config.eventTypes.contains(.revenueEvent) else { return }
        
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterItemID : revenueEvent.productIdentifier ?? "",
            AnalyticsParameterPrice: revenueEvent.price,
            AnalyticsParameterCurrency: revenueEvent.currency ?? ""
        ])
    }
    
    public func adEvent(_ adEvent: FXAdEvent) {
        
        guard config.eventTypes.contains(.adViewEvent) else { return }
        
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterAdSource : adEvent.source,
            AnalyticsParameterAdUnitName: adEvent.productId,
            AnalyticsParameterAdFormat: adEvent.adType,
        ])
    }
    
    public func setUserId(_ userId: String) {
        Analytics.setUserID(userId)
    }
    
}

