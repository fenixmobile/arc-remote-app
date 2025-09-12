//
//  AdaptyFXPurchaseProfileParameters.swift
//  FXPurchase
//
//  Created by Savaş Salihoğlu on 24.10.2023.
//

import Foundation
import Adapty
import AppTrackingTransparency

@available(iOS 14, *)
public struct AdaptyFXPurchaseProfileParameters {
    public var appTrackingTransparencyStatus: ATTrackingManager.AuthorizationStatus? = nil
    
    public init(appTrackingTransparencyStatus: ATTrackingManager.AuthorizationStatus? = nil) {
        self.appTrackingTransparencyStatus = appTrackingTransparencyStatus
    }
}

@available(iOS 14, *)
extension AdaptyFXPurchaseProfileParameters {
    func toAdaptyProfileParameters() -> AdaptyProfileParameters {
        print("FXTEST: ATTrackingManager.trackingAuthorizationStatus", ATTrackingManager.trackingAuthorizationStatus)
        let builder = AdaptyProfileParameters.Builder()
            .with(appTrackingTransparencyStatus: self.appTrackingTransparencyStatus)
        
        return builder.build()
    }
}
