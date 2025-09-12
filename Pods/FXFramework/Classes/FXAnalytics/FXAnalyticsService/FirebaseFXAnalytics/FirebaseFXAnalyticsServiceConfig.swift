//
//  FirebaseFXAnalyticsConfig.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 17.10.2023.
//

import Foundation

public struct FirebaseFXAnalyticsServiceConfig: FXAnalyticsServiceConfig {
    
    let eventTypes: [FXEventType]
    
    public init(eventTypes: [FXEventType]) {
        self.eventTypes = eventTypes
    }
    
}
