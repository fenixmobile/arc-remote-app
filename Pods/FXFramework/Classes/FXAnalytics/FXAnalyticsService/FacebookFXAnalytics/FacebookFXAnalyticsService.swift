//
//  FacebookFXAnalytics.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 23.10.2023.
//

import Foundation

public protocol FacebookFXAnalyticsService: FXAnalyticsService {
}

extension FacebookFXAnalyticsService {
    public var analyticsServiceType: FXAnalyticsServiceType {
        .facebook
    }
}
