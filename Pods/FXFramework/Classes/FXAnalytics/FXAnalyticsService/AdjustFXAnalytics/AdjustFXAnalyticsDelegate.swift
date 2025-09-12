//
//  AdjustFXAnalyticsDelegate.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 23.10.2023.
//

import Foundation

public protocol AdjustFXAnalyticsServiceDelegate {
    
    func AdjustFXAnalyticsServiceAttributionChanged(_ attribution : [AnyHashable : Any])
    func AdjustFXAnalyticsServiceSetIntegrationId(_ key : String, value : String) async
}
