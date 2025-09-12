//
//  FXAnalyticsConfig.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 25.10.2023.
//

import Foundation

public struct FXAnalyticsConfig {
    
    var analyticsServiceTypes: [(FXAnalyticsServiceType, [FXEventType])]
    
    public var amplitudeApiKey: String?
    public var amplitudeDeviceId: String?
    
    public var adjustAppToken: String?
    public var environment: AdjustFXEnvironment?
    public var tokenDelegate: AdjustFXAnalyticsServiceTokenDelegate?
    
    public init(analyticsServiceTypes: [(FXAnalyticsServiceType, [FXEventType])]) {
        self.analyticsServiceTypes = analyticsServiceTypes
    }

}
