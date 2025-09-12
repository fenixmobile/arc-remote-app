//
//  AdaptyPaywallProduct+toAdaptyFXProduct.swift
//  FXPurchase
//
//  Created by Savaş Salihoğlu on 16.10.2023.
//

import Foundation
import Adapty

extension AdaptyPaywallProduct {
    func toAdaptyFXProduct() -> AdaptyFXProduct {
        return .init(adaptyProduct: self)
    }
}
