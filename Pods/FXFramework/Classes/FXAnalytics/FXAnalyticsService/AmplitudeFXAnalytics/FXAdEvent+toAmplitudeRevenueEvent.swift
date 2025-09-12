//
//  FXAdEvent+toAmplitudeRevenueEvent.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 30.10.2023.
//

import Foundation
import AmplitudeSwift

extension FXAdEvent {
    func toAmplitudeRevenueEvent() -> Revenue {
        let revenue = Revenue()
        revenue.price = price
        revenue.quantity = 1
        revenue.revenueType = "view_ad"
        revenue.properties = ["Ad Type": adType, source: source]
        return revenue
    }
}
