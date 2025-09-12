//
//  AmplitudeFXAnalyticsConfig.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 23.10.2023.
//

import Foundation

public struct AmplitudeFXAnalyticsServiceConfig: FXAnalyticsServiceConfig {
    
    let eventTypes: [FXEventType]
    let apiKey: String
    let deviceId: String?
    
    public init(apiKey: String, deviceId: String?, eventTypes: [FXEventType]) {
        self.apiKey = apiKey
        self.deviceId = deviceId
        self.eventTypes = eventTypes
    }
}

