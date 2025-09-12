//
//  DefaultFXPurchaseConfig.swift
//  FXPurchase
//
//  Created by Savaş Salihoğlu on 17.10.2023.
//

import Foundation

public class DefaultFXPurchaseConfig: FXPurchaseConfig {
    
    public var localeCode: String?
    
    public init(localeCode: String) {
        self.localeCode = localeCode
    }
}
