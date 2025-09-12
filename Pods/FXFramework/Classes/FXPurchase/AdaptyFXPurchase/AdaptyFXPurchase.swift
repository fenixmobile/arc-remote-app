//
//  AdaptyFXPurchase.swift
//  FXPurchase
//
//  Created by Savaş Salihoğlu on 13.10.2023.
//

import Foundation
import Adapty

enum AdaptyFXPurchaseError: Error {
    case missingAdaptyPaywall
    case any(Error)
}

public class AdaptyFXPurchase: FXPurchase {
    
    var config: AdaptyFXPurchaseConfig
    
    public init(config: AdaptyFXPurchaseConfig) {
        self.config = config
        let configurationBuilder =
            AdaptyConfiguration
            .builder(withAPIKey: config.apiKey)
            .with(logLevel: .debug)
            .with(idfaCollectionDisabled: false)

        Adapty.activate(with: configurationBuilder.build()) { error in
            print("FXTEST: Adapty initialization completed: error:", error ?? "")
          }
    }
    
    public func setExternalUserId(_ externalUserId: String,
                                  _ completion: fxPurchaseErrorCompletion?) {
        Adapty.identify(externalUserId) {  error in
            if let error = error, let completion = completion {
                completion(FXPurchaseError.any(error))
                FXLog.error("set_external_user_id: \(error.description)")
            } else {
                completion?(nil)
            }
        }
    }
    
    public func getPaywall(by identifier: String,
                    completion: @escaping fxPaywallCompletion) {
        Adapty.getPaywall(placementId: identifier, locale: config.localeCode) { adaptyResult in
            switch adaptyResult {
            case .success(let paywall):
                FXLog.info("adapty_paywall_success \(paywall.name)")
                completion(.success(paywall.toFXPaywall()))
            case .failure(let error):
                FXLog.error("adapty_paywall_fail: \(error.description)")
                completion(.failure(FXPurchaseError.any(error)))
            }
        }
    }
    
    public func getProducts(by paywall: FXPaywall?,
                     completion: @escaping fxProductsCompletion) {
        guard let adaptyFXPaywall = paywall as? AdaptyFXPaywall,
              let adaptyPaywall = adaptyFXPaywall.adaptyPaywall else {
            completion(.failure(AdaptyFXPurchaseError.missingAdaptyPaywall))
            return
        }
        
        Adapty.getPaywallProducts(paywall: adaptyPaywall) { adaptyResult in
            switch adaptyResult {
            case .success(let products):
                FXLog.info("adapty_products_success:")
                let products = products.map{ $0.toAdaptyFXProduct() }
                adaptyFXPaywall.setProducts(products)
                completion(.success(products))
            case .failure(let error):
                FXLog.error("adapty_products_fail: \(error.description)")
            }
        }
    }
    
    public func startPurchase(with product: FXProduct,
                       completion: @escaping fxPurchaseResultCompletion) {
        guard let adaptyFXProduct = product as? AdaptyFXProduct else {
            completion(.failure(AdaptyFXPurchaseError.missingAdaptyPaywall))
            return
        }
        
        Adapty.makePurchase(product: adaptyFXProduct.adaptyProduct) { adaptyResult in
            switch adaptyResult {
            case .success(let adaptyPurchasedInfo):
                FXLog.info("adapty_purchased_success:")
                var premium = false
                if let active = adaptyPurchasedInfo.profile?.accessLevels["premium"]?.isActive {
                    premium = active
                }
                let activeOfferType = adaptyPurchasedInfo.profile?.accessLevels["premium"]?.activeIntroductoryOfferType ?? ""
                completion(.success(.init(info: ["premium": premium],
                                          customerUserId: adaptyPurchasedInfo.profile?.customerUserId,
                                          activeOfferType: activeOfferType)))
            case .failure(let error):
                FXLog.error("adapty_purchased_fail: \(error.description)")
                completion(.failure(AdaptyFXPurchaseError.any(error)))
            }
        }
    }
    
    public func restore(completion: @escaping fxPurchaseResultCompletion) {
        Adapty.restorePurchases { adaptyResult in
            switch adaptyResult {
            case .success(let adaptyProfile):
                FXLog.info("adapty_restore_success: ")
                var premium = false
                if let active = adaptyProfile.accessLevels["premium"]?.isActive {
                    premium = active
                }
                let activeOfferType = adaptyProfile.accessLevels["premium"]?.activeIntroductoryOfferType ?? ""
                completion(.success(.init(info: ["premium": premium],
                                          customerUserId: adaptyProfile.customerUserId,
                                          activeOfferType: activeOfferType)))
            case .failure(let error):
                FXLog.error("adapty_restore_fail: \(error.description)")
                completion(.failure(AdaptyFXPurchaseError.any(error)))
            }
        }
    }
    
    public func updateAttribution(attribution : [AnyHashable : Any],
                                  source: String) {
        print("TEST: updateAttribution source: ", source)
        Adapty.updateAttribution(attribution, source: source)
    }
    
    public func setIntegrationIdentifier(key: String, value: String) async {
        do {
            try await Adapty.setIntegrationIdentifier(key: key, value: value)
        } catch {
            FXLog.error("Set integration id error \(key)")
        }
    }
    
    @available(iOS 14, *)
    public func updateProfile(params: AdaptyFXPurchaseProfileParameters) {
        Adapty.updateProfile(params: params.toAdaptyProfileParameters())
    }
    
    public func logShowPaywall(_ paywall: FXPaywall,
                               _ completion: fxPurchaseErrorCompletion?) {
        guard let paywall = paywall as AnyObject as? AdaptyFXPaywall,
        let adaptyPaywall = paywall.adaptyPaywall else {
            if let completion = completion {
                completion(FXPurchaseError.error("cannot cast paywall to AdaptyPaywall"))
                FXLog.error("log_show_paywall: cannot cast paywall to AdaptyPaywall")
            }
            return
        }
        Adapty.logShowPaywall(adaptyPaywall) { error in
            if let error = error, let completion = completion {
                completion(FXPurchaseError.any(error))
                FXLog.error("log_show_paywall: \(error.description)")
            }
        }
    }
    
    public func getPurchaseInfo(completion: @escaping fxPurchaseResultCompletion) {
        Adapty.getProfile { result in
            do {
                let profile = try result.get()
                let premium = profile.accessLevels["premium"]?.isActive ?? false
                let activeOfferType = profile.accessLevels["premium"]?.activeIntroductoryOfferType ?? ""
                let purchaseInfo: FXPurchaseInfo = .init(info: ["premium": premium],
                                                         customerUserId: profile.customerUserId,
                                                         activeOfferType: activeOfferType)
                completion(.success(purchaseInfo))
            } catch {
                completion(.failure(AdaptyFXPurchaseError.any(error)))
            }
        }
    }
}
