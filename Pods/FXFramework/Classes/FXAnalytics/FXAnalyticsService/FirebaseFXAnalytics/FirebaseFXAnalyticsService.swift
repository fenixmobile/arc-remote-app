//
//  IFirebaseFXAnalytics.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 24.10.2023.
//

import Foundation

public protocol FirebaseFXAnalyticsService: FXAnalyticsService {
    var firebaseInstanceId: String? { get }
}

extension FirebaseFXAnalyticsService {
    public var analyticsServiceType: FXAnalyticsServiceType {
        .firebase
    }
}
