//
//  AnalyticsManager.swift
//  rokutv
//
//  Created by fnx macbook on 26.02.2024.
//

import Foundation
import FXFramework

enum AnalyticsEvent: String {
    case startTrial = "adjust_start_trial"
    case startSubsctiption = "adjust_start_subscription"
    case startPro = "adjust_start_pro"
}

class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    
    private let initializationQueue = DispatchQueue(label: "com.rokutv.analytics.init")
    private var _fxAnalytics: FXAnalytics?
    
    var fxAnalytics: FXAnalytics {
        if let analytics = _fxAnalytics {
            return analytics
        }
        
        return initializationQueue.sync {
            if let analytics = _fxAnalytics {
                return analytics
            }
            
            var config = FXAnalyticsConfig(analyticsServiceTypes: [
                
                (.adjust, [.revenueEvent, .default]),
                (.firebase, [.revenueEvent, .default]),
                (.amplitude, [.adViewEvent, .revenueEvent, .default]),
                (.facebook, [])
            ])
            
            config.adjustAppToken = Constants.Analytics.adjustAppToken
#if DEBUG
            config.environment = .adjustFXEnvironmentSandbox
#else
            config.environment = .adjustFXEnvironmentProduction
#endif
            config.tokenDelegate = self
            
            config.amplitudeApiKey = Constants.Analytics.amplitudeApiKey
            config.amplitudeDeviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
             
            let analytics: FXAnalytics = FX.shared.initAnalytics(with: config)
            _fxAnalytics = analytics
            return analytics
        }
    }
}

extension AnalyticsManager: AdjustFXAnalyticsServiceTokenDelegate {
    func getToken(by event: String) -> String? {
        switch event {
        case AnalyticsEvent.startTrial.rawValue:
#if DEBUG
            return "k1kg94" //test
#else
            return "qukxta" //product
#endif
        case AnalyticsEvent.startSubsctiption.rawValue:
#if DEBUG
            return "4u4dby" //test
#else
            return "221yy6" //product
#endif
        case AnalyticsEvent.startPro.rawValue:
#if DEBUG
            return "7ehjju" //test
#else
            return "w0a1rh" //product
#endif
        default:
            return nil
        }
    }
}
