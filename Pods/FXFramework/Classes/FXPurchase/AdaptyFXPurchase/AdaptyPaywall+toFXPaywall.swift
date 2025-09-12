//
//  AdaptyPaywall+toFXPaywall.swift
//  FXPurchase
//
//  Created by Savaş Salihoğlu on 16.10.2023.
//

import Foundation
import Adapty

extension AdaptyPaywall {
    func toFXPaywall() -> AdaptyFXPaywall {
        return .init(identifier: placementId,
                     variationId: variationId,
                     name: name,
                     locale: remoteConfig?.locale ?? "",
                     remoteConfig: remoteConfig?.dictionary,
                     adaptyPaywall: self)
    }
}
