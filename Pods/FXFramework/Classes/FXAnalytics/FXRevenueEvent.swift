//
//  FXRevenueEvent.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 27.10.2023.
//

import Foundation

public struct FXRevenueEvent {
    let event: String?
    let productIdentifier: String?
    let quantity: Int
    let price: Double
    let currency: String?
    let revenueType: String
    let eventProperties: [AnyHashable: Any]?
    let receipt: Data?
    
    public init(event: String?,
                productIdentifier: String?,
                quantity: Int,
                price: Double,
                currency: String?,
                revenueType: String,
                eventProperties: [AnyHashable : Any]?,
                receipt: Data?) {
        self.event = event
        self.productIdentifier = productIdentifier
        self.quantity = quantity
        self.price = price
        self.currency = currency
        self.revenueType = revenueType
        self.eventProperties = eventProperties
        self.receipt = receipt
    }
}
