//
//  AdaptyFXPaywall.swift
//  FXPurchase
//
//  Created by Savaş Salihoğlu on 16.10.2023.
//

import Foundation
import Adapty

class AdaptyFXPaywall: FXPaywall {
    var identifier: String
    var variationId: String?
    var name: String
    var locale: String
    var remoteConfig: [String : Any]?
    var products: [FXProduct]?
    var adaptyPaywall: AdaptyPaywall?
    
    init(identifier: String,
         variationId: String,
         name: String,
         locale: String,
         remoteConfig: [String : Any]? = nil,
         products: [FXProduct]? = nil,
         adaptyPaywall: AdaptyPaywall? = nil) {
        self.identifier = identifier
        self.variationId = variationId
        self.name = name
        self.locale = locale
        self.remoteConfig = remoteConfig
        self.products = products
        self.adaptyPaywall = adaptyPaywall
    }
    
    public func setProducts(_ products: [FXProduct]) {
        self.products = products
    }
}
