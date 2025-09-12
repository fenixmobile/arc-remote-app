//
//  AdjustFXAnalyticsConfig.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 23.10.2023.
//

import Foundation

public struct AdjustFXAnalyticsServiceConfig: FXAnalyticsServiceConfig {
    
    let eventTypes: [FXEventType]
    let appToken: String
    let environment: AdjustFXEnvironment
    let tokenDelegate: AdjustFXAnalyticsServiceTokenDelegate?
    
    public init(appToken: String,
                environment: AdjustFXEnvironment,
                tokenDelegate: AdjustFXAnalyticsServiceTokenDelegate?,
                eventTypes: [FXEventType]) {
        self.appToken = appToken
        self.environment = environment
        self.tokenDelegate = tokenDelegate
        self.eventTypes = eventTypes
    }
    
}
