//
//  FXProduct.swift
//
//
//  Created by Savaş Salihoğlu on 10.10.2023.
//

import Foundation
import StoreKit

public protocol FXProduct {
    var productId: String { get }
    var sk1Product: SKProduct? { get }
    @available(iOS 15.0, *)
    var sk2Product: Product? { get }
    var promotionalOfferId: String? { get }
}

extension FXProduct {
    public var productId: String? {
        if #available(iOS 15.0, *), let sk2Product = sk2Product {
            return sk2Product.id
        }
        if let sk1Product = sk1Product {
            return sk1Product.productIdentifier
        }
        return nil
    }
    public var localizedDescription: String? {
        if #available(iOS 15.0, *), let sk2Product = sk2Product {
            return sk2Product.description
        }
        if let sk1Product = sk1Product {
            return sk1Product.localizedDescription
        }
        return nil
    }
    public var localizedTitle: String? {
        if #available(iOS 15.4, *), let sk2Product = sk2Product {
            return sk2Product.displayName
        }
        if let sk1Product = sk1Product {
            return sk1Product.localizedTitle
        }
        return nil
    }
    
    public var currencyCode: String? {
        if #available(iOS 16, *) {
            if let sk2Product = sk2Product {
                return sk2Product.priceFormatStyle.currencyCode
            }
            if let sk1Product = sk1Product {
                return sk1Product.priceLocale.currency?.identifier
            }
        }
        return nil
        
    }
    public var price: Decimal? {
        if #available(iOS 15.0, *), let sk2Product = sk2Product {
            return sk2Product.price
        }
        if let sk1Product = sk1Product {
            return sk1Product.price.decimalValue
        }
        return nil
    }
}
