//
//  FXAdEvent.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 27.10.2023.
//

import Foundation

public struct FXAdEvent {
    let productId: String
    let price: Double
    let adType: String
    let source: String
    
    public init(productId: String,
                price: Double,
                adType: String,
                source: String) {
        self.productId = productId
        self.price = price
        self.adType = adType
        self.source = source
    }
}
