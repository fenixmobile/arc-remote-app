//
//  FXAnalyticsType.swift
//
//
//  Created by Savaş Salihoğlu on 9.10.2023.
//

import Foundation
import AppTrackingTransparency
import AdSupport

public protocol FXAnalyticsService {
    
    func logEvent(_ event: String, properties: [String : Any]?)
    func setProperty(_ property: String, value: String)
    func revenueEvent(_ revenueEvent: FXRevenueEvent)
    func adEvent(_ adEvent: FXAdEvent)
    
    func setUserId(_ userId: String)
    
    var analyticsServiceType: FXAnalyticsServiceType { get }
}
