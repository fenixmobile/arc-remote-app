//
//  FacebookFXAnalyticsConfig.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 23.10.2023.
//

import Foundation

public struct FacebookFXAnalyticsServiceConfig: FXAnalyticsServiceConfig {
    
    let eventTypes: [FXEventType]
    
    public init(eventTypes: [FXEventType]) {
        self.eventTypes = eventTypes
    }
    
}
