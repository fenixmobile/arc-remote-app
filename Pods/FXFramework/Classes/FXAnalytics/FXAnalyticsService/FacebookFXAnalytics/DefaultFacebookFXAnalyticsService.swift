//
//  DefaultFacebookFXAnalytics.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 24.10.2023.
//

import Foundation
import FBSDKCoreKit

public class DefaultFacebookFXAnalyticsService: FacebookFXAnalyticsService {
   
    let config: FacebookFXAnalyticsServiceConfig
    
    public init(config: FacebookFXAnalyticsServiceConfig) {
        self.config = config
    }
    
    public func logEvent(_ event: String, properties: [String : Any]?) {
        guard config.eventTypes.contains(.default) else { return }
    }
    
    public func setProperty(_ property: String, value: String) {
        guard config.eventTypes.contains(.property) else { return }
        
    }
    
    public func revenueEvent(_ revenueEvent: FXRevenueEvent) {
        guard config.eventTypes.contains(.revenueEvent) else { return }
    }
    
    public func adEvent(_ adEvent: FXAdEvent) {
        guard config.eventTypes.contains(.adViewEvent) else { return }
    }
    
    public func setUserId(_ userId: String) {
        AppEvents.shared.userID = userId
    }
}
