//
//  FXPurchaseInfo.swift
//
//
//  Created by Savaş Salihoğlu on 11.10.2023.
//

import Foundation
import StoreKit

public struct FXPurchaseInfo {
    public let info: [String: Any]
    public let customerUserId: String?
    //public let paymentTransaction: SKPaymentTransaction
    public let activeOfferType: String?
}
