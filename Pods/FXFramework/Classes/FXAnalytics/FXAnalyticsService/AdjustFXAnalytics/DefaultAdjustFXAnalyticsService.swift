//
//  DefaultFXAnalytics.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 24.10.2023.
//

import Foundation
import AdjustSdk

public class DefaultAdjustFXAnalyticsService: NSObject, AdjustFXAnalyticsService {
    
    var config: AdjustFXAnalyticsServiceConfig
    
    public var delegate: AdjustFXAnalyticsServiceDelegate?
    public var tokenDelegate: AdjustFXAnalyticsServiceTokenDelegate?
    
    var adjustConfig: ADJConfig?
    
    public init(config: AdjustFXAnalyticsServiceConfig) {
        self.config = config
        tokenDelegate = config.tokenDelegate
        super.init()
        initializeAdjust()
    }
    
    public func logEvent(_ event: String, properties: [String : Any]?) {
        guard config.eventTypes.contains(.default) else { return }
        
        guard let token = tokenDelegate?.getToken(by: event) else { return }
        let event = ADJEvent(eventToken: token)
        Adjust.trackEvent(event)
    }
    
    public func setProperty(_ property: String, value: String) {
        guard config.eventTypes.contains(.property) else { return }
        Adjust.addGlobalPartnerParameter(value, forKey: property)
    }
    
    public func revenueEvent(_ revenueEvent: FXRevenueEvent) {
        guard config.eventTypes.contains(.revenueEvent) else { return }
        
        guard let event = revenueEvent.event,
              let token = tokenDelegate?.getToken(by: event) else { return }
        
        let adjustEvent = ADJEvent(eventToken: token)
        adjustEvent?.setRevenue(revenueEvent.price, currency: revenueEvent.currency ?? "USD")
        Adjust.trackEvent(adjustEvent)
        
    }
    
    public func adEvent(_ adEvent: FXAdEvent) {
        guard config.eventTypes.contains(.adViewEvent) else { return }
    }
    
    public func setUserId(_ userId: String) {
        print("TEST: adjust external device id", userId)
        adjustConfig?.externalDeviceId = userId
    }
    
    private func initializeAdjust() {
        adjustConfig = ADJConfig(
            appToken: config.appToken,
            environment: config.environment.ajdEnvironment)
     
        adjustConfig?.delegate = self
        adjustConfig?.attConsentWaitingInterval = 30
        Adjust.initSdk(adjustConfig)
        updateAdjustAdid()
    }
    
    func updateAdjustAdid() {
        Adjust.adid { adid in
            guard let adid else { return }
            Task {
                await self.delegate?.AdjustFXAnalyticsServiceSetIntegrationId("adjust_device_id", value: adid)
            }
        }
    }
    
    public func requestATT(_ completion: @escaping (UInt) -> Void) {
        Adjust.requestAppTrackingAuthorization { status in
            completion(status)
        }
    }
    
}
/*
extension DefaultAdjustFXAnalyticsService {
    
    func updateAdjustAdid() {
        Adjust.adid { adid in
            guard let adid else { return }
            delegate?.AdjustFXAnalyticsServiceAttributionChanged(attribution)
            Adapty.setIntegrationIdentifier(key: "adjust_device_id", value: adid)
        }
    }
    public func updateAdjustAttribution() {
        Adjust.attribution { attribution in
            guard let attribution = attribution?.dictionary() else {
                return
            }
            delegate?.AdjustFXAnalyticsServiceAttributionChanged(attribution)
            //Adapty.updateAttribution(attribution, source: "adjust")
        }
    }
}
 */

extension DefaultAdjustFXAnalyticsService {
    public func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        print("FXTEST: adjustAttributionChanged")
        if let attribution = attribution?.dictionary() {
            print("FXTEST: adjustAttributionChanged attribution?.dictionary")
            delegate?.AdjustFXAnalyticsServiceAttributionChanged(attribution)
        }
    }
}

