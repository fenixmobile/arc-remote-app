//
//  AdaptyFXPurchaseConfig.swift
//  FXPurchase
//
//  Created by Savaş Salihoğlu on 16.10.2023.
//

import Foundation

public class AdaptyFXPurchaseConfig: FXPurchaseConfig {
    
    let apiKey: String
    public var localeCode: String?
    
    public init(apiKey: String,
         localeCode: String) {
        self.apiKey = apiKey
        self.localeCode = localeCode
    }
    
}
