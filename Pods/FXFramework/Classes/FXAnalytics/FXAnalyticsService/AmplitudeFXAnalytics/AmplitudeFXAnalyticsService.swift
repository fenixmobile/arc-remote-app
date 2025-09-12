//
//  AmplitudeFXAnalytics.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 17.10.2023.
//

import Foundation

public protocol AmplitudeFXAnalyticsService: FXAnalyticsService {
    var userId: String? { get }
    var deviceId: String? { get }
}

extension AmplitudeFXAnalyticsService {
    public var analyticsServiceType: FXAnalyticsServiceType {
        .amplitude
    }
}
