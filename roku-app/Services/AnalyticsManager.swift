import Foundation
import FXFramework

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    let fxAnalytics: FXAnalytics
    
    private init() {
        let analyticsServiceTypes: [(FXAnalyticsServiceType, [FXEventType])] = [
            (.firebase, [.default, .revenueEvent, .adViewEvent]),
            (.amplitude, [.default, .revenueEvent, .adViewEvent]),
            (.adjust, [.default, .revenueEvent, .adViewEvent]),
            (.facebook, [.default, .revenueEvent, .adViewEvent])
        ]
        let config = FXAnalyticsConfig(analyticsServiceTypes: analyticsServiceTypes)
        fxAnalytics = FX.shared.initAnalytics(with: config)
    }
}