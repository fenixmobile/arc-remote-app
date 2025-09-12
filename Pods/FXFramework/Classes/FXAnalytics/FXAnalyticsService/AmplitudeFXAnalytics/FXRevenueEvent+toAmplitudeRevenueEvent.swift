//
//  FXRevenueEvent+toAmplitudeRevenueEvent.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 29.10.2023.
//


import AmplitudeSwift

extension FXRevenueEvent {
    func toAmplitudeRevenueEvent() -> Revenue {
        let revenue = Revenue()
        revenue.price = price
        revenue.quantity = quantity
        revenue.productId = productIdentifier
        if let eventProperties = eventProperties {
            let stringDict = Dictionary(uniqueKeysWithValues: eventProperties.compactMap { key, value in
                (key as? String).map { ($0, value) }
            })
            revenue.properties = stringDict
        }
        return revenue
    }
}
