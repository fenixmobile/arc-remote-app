//
//  DefaultAmplitudeFXAnalytics.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 24.10.2023.
//

import Foundation
import AmplitudeSwift

public class DefaultAmplitudeFXAnalyticsService: AmplitudeFXAnalyticsService {
    
    var amplitude: Amplitude?
    
    public var userId: String? {
        amplitude?.getUserId()
    }
    
    public var deviceId: String? {
        amplitude?.getDeviceId()
    }
    
    let config: AmplitudeFXAnalyticsServiceConfig
    
    public init(config: AmplitudeFXAnalyticsServiceConfig) {
        self.config = config
        initializeAmplitude()
    }
    
    public func logEvent(_ event: String, properties: [String : Any]?) {
        
        guard config.eventTypes.contains(.default) else { return }
        
        amplitude?.track(eventType: event, eventProperties: properties)
    }
    
    public func setProperty(_ property: String, value: String) {
        
        guard config.eventTypes.contains(.property) else { return }
        amplitude?.identify(userProperties: [property: value])
    }
    
    public func revenueEvent(_ revenueEvent: FXRevenueEvent) {
        
        guard config.eventTypes.contains(.revenueEvent) else { return }
        
        amplitude?.revenue(revenue: revenueEvent.toAmplitudeRevenueEvent())
    }
    
    public func adEvent(_ adEvent: FXAdEvent) {
        
        guard config.eventTypes.contains(.adViewEvent) else { return }
        
        amplitude?.revenue(revenue: adEvent.toAmplitudeRevenueEvent())
    }
    
    public func setUserId(_ userId: String) {
        amplitude?.setUserId(userId: userId)
    }
    
    public func setDeviceId(_ deviceId: String) {
        amplitude?.setDeviceId(deviceId: deviceId)
    }
    
    private func initializeAmplitude() {
        
        amplitude = Amplitude(configuration: Configuration(
            apiKey: config.apiKey,
            defaultTracking: DefaultTrackingOptions(
                screenViews: true
            ),
            migrateLegacyData: false
        ))
        amplitude?.setDeviceId(deviceId: config.deviceId)
        
    }
}
