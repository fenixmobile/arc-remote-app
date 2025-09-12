//
//  FXAnalytics.swift
//
//
//  Created by Savaş Salihoğlu on 6.10.2023.
//

import Foundation
import AdSupport

public protocol FXAnalytics {
    func send(event: String,
              properties: [String : Any]?,
              onlyFor analyticServiceType: FXAnalyticsServiceType?)
    func revenueEvent(_ revenueEvent: FXRevenueEvent,
                      onlyFor analyticServiceType: FXAnalyticsServiceType?)
    func adEvent(_ adEvent: FXAdEvent,
                 onlyFor analyticServiceType: FXAnalyticsServiceType?)
    func setProperty(_ property: String, value: String,
                     onlyFor analyticServiceType: FXAnalyticsServiceType?)
    
    func setUserId(_ userId: String)
}

extension FXAnalytics {
    public func send(event: String,
              properties: [String : Any]? = nil,
              onlyFor analyticServiceType: FXAnalyticsServiceType? = nil) {
        send(event: event, properties: properties, onlyFor: analyticServiceType)
    }
    
    public func revenueEvent(_ revenueEvent: FXRevenueEvent,
                      onlyFor analyticServiceType: FXAnalyticsServiceType? = nil) {
        self.revenueEvent(revenueEvent, onlyFor: analyticServiceType)
    }
    
    public func adEvent(_ adEvent: FXAdEvent,
                 onlyFor analyticServiceType: FXAnalyticsServiceType? = nil) {
        self.adEvent(adEvent, onlyFor: analyticServiceType)
    }
}

