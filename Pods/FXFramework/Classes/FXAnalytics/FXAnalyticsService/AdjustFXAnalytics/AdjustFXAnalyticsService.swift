//
//  AdjustFXAnalytics.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 23.10.2023.
//

import Foundation
import AdjustSdk

public protocol AdjustFXAnalyticsService: FXAnalyticsService, AdjustDelegate {
    var delegate: AdjustFXAnalyticsServiceDelegate? { get set }
    func requestATT(_ completion: @escaping (UInt) -> Void)
}

extension AdjustFXAnalyticsService {
    public var analyticsServiceType: FXAnalyticsServiceType {
        .adjust
    }
}
