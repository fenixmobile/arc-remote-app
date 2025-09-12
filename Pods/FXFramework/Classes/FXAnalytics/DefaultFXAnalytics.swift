//
//  DefaultFXAnalytics.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 25.10.2023.
//

import Foundation
import AppTrackingTransparency
import AdSupport

public class DefaultFXAnalytics: FXAnalytics {
    
    public var adjustFXAnalyticsService: AdjustFXAnalyticsService?
    public var firebaseFXAnalyticsService: FirebaseFXAnalyticsService?
    public var amplitudeFXAnalyticsService: AmplitudeFXAnalyticsService?
    public var facebookFXAnalyticsService: FacebookFXAnalyticsService?
    
    var analyticsServices: [FXEventType: [FXAnalyticsService]] = [.revenueEvent: [], .adViewEvent: [], .default: []]
    
    let config: FXAnalyticsConfig
    
    public init(config: FXAnalyticsConfig) {
        self.config = config
        setServices()
    }
    
    private func setServices() {
        config.analyticsServiceTypes.forEach { serviceType, eventTypes in
            switch serviceType {
            case .adjust:
                print("FXTEST: analyticsServiceTypes adjust")
                guard let adjustAppToken = config.adjustAppToken, let environment = config.environment else {
                    FXLog.warn("AdjustFXAnalyticsService initializing failed; app-token or environment missing")
                    return
                }
                let adjustFXAnalyticsService = DefaultAdjustFXAnalyticsService(config: .init(appToken: adjustAppToken,
                                                                                             environment: environment,
                                                                                             tokenDelegate: config.tokenDelegate,
                                                                                             eventTypes: eventTypes))
                self.adjustFXAnalyticsService = adjustFXAnalyticsService
                print("FXTEST: analyticsServiceTypes eventTypes:", eventTypes)
                eventTypes.forEach{ analyticsServices[$0]?.append( adjustFXAnalyticsService) }
                
            case .amplitude:
                guard let amplitudeApiKey = config.amplitudeApiKey, let amplitudeDeviceId = config.amplitudeDeviceId else {
                    FXLog.warn("amplitudeFXAnalyticsService initializing failed; api-key or device-id missing")
                    return }
                let amplitudeFXAnalyticsService = DefaultAmplitudeFXAnalyticsService(config: .init(apiKey: amplitudeApiKey,
                                                                                                   deviceId: amplitudeDeviceId,
                                                                                                   eventTypes: eventTypes))
                self.amplitudeFXAnalyticsService = amplitudeFXAnalyticsService
                eventTypes.forEach{ analyticsServices[$0]?.append( amplitudeFXAnalyticsService) }
            case .facebook:
                let facebookFXAnalyticsService = DefaultFacebookFXAnalyticsService(config: .init(eventTypes: eventTypes))
                self.facebookFXAnalyticsService = facebookFXAnalyticsService
                eventTypes.forEach{ analyticsServices[$0]?.append( facebookFXAnalyticsService) }
            case .firebase:
                let firebaseFXAnalyticsService = DefaultFirebaseFXAnalyticsService(config: .init(eventTypes: eventTypes))
                self.firebaseFXAnalyticsService = firebaseFXAnalyticsService
                eventTypes.forEach{ analyticsServices[$0]?.append( firebaseFXAnalyticsService) }
            }
        }
    }
    
    public func send(event: String,
              properties: [String : Any]?,
              onlyFor analyticServiceType: FXAnalyticsServiceType?) {
        
        if let analyticServiceType = analyticServiceType,
           let analyticsService = getAnalyticService(by:  analyticServiceType) {
            analyticsService.logEvent(event, properties: properties)
            return
        }
        
        analyticsServices[.default]?.forEach{ $0.logEvent(event, properties: properties) }
    }
    
    public func setProperty(_ property: String,
                            value: String,
                            onlyFor analyticServiceType: FXAnalyticsServiceType?) {
        if let analyticServiceType = analyticServiceType,
           let analyticsService = getAnalyticService(by:  analyticServiceType) {
            analyticsService.setProperty(property, value: value)
            return
        }
        analyticsServices[.property]?.forEach{ $0.setProperty(property, value: value) }
    }
    
    public func revenueEvent(_ revenueEvent: FXRevenueEvent,
                             onlyFor analyticServiceType: FXAnalyticsServiceType?) {
        
        if let analyticServiceType = analyticServiceType,
           let analyticsService = getAnalyticService(by:  analyticServiceType) {
            analyticsService.revenueEvent(revenueEvent)
            return
        }
        
        analyticsServices[.revenueEvent]?.forEach{ $0.revenueEvent(revenueEvent) }
    }
    
    public func adEvent(_ adEvent: FXAdEvent,
                 onlyFor analyticServiceType: FXAnalyticsServiceType?) {
        
        if let analyticServiceType = analyticServiceType,
           let analyticsService = getAnalyticService(by:  analyticServiceType) {
            analyticsService.adEvent(adEvent)
            return
        }
        
        analyticsServices[.adViewEvent]?.forEach{ $0.adEvent(adEvent) }
    }
    
    public func setUserId(_ userId: String) {
        adjustFXAnalyticsService?.setUserId(userId)
        firebaseFXAnalyticsService?.setUserId(userId)
        amplitudeFXAnalyticsService?.setUserId(userId)
        facebookFXAnalyticsService?.setUserId(userId)
    }
    
    
    private func getAnalyticService(by analyticServiceType: FXAnalyticsServiceType) -> FXAnalyticsService? {
        switch analyticServiceType {
        case .adjust:
            return adjustFXAnalyticsService
        case .amplitude:
            return amplitudeFXAnalyticsService
        case .facebook:
            return facebookFXAnalyticsService
        case .firebase:
            return firebaseFXAnalyticsService
        }
    }
}
 
