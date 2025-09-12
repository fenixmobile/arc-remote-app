//
//  AdaptyFXProduct.swift
//  FXPurchase
//
//  Created by Savaş Salihoğlu on 16.10.2023.
//

import Foundation
import StoreKit
import Adapty

struct AdaptyFXProduct: FXProduct {
    let adaptyProduct: AdaptyPaywallProduct
    
    var sk1Product: SKProduct? {
        return adaptyProduct.sk1Product
    }
    
    @available(iOS 15.0, *)
    var sk2Product: Product? {
        return adaptyProduct.sk2Product
    }
    
    var productId: String {
        return adaptyProduct.vendorProductId
    }
    
    var promotionalOfferId: String? {
        return adaptyProduct.subscriptionOffer?.identifier
    }
    

}
