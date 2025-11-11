//
//  PaywallHelper.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
//

import UIKit
import FXFramework

extension FXProduct {
    var localizedPrice: String? {
        if #available(iOS 15.0, *), let sk2Product = sk2Product {
            print("sk2Product.displayPrice", sk2Product.displayPrice)
            return sk2Product.displayPrice
        }
        if let sk1Product = sk1Product {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = sk1Product.priceLocale
            let price = formatter.string(from: sk1Product.price) ?? ""
            print("sk1Product.price", price)
            return price
        }
        return nil
    }
}

class PaywallHelper {
    static let shared = PaywallHelper()
    
    var fxPurchase: FXPurchase?
    private let cacheManager = PaywallCacheManager.shared
    
    private init() {
        setupFXPurchase()
    }
    
    private func setupFXPurchase() {
        let config = AdaptyFXPurchaseConfig(apiKey: Constants.Adapty.apiKey, localeCode: Constants.Adapty.localeCode)
        fxPurchase = AdaptyFXPurchase(config: config)
    }
    
    func loadPaywall(placementId: String, completion: @escaping (Result<FXPaywall, Error>) -> Void) {
        fxPurchase?.getPaywall(by: placementId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paywall):
                    self?.cacheManager.storePaywall(paywall, for: placementId)
                    completion(.success(paywall))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func loadProducts(paywall: FXPaywall, completion: @escaping (Result<[FXProduct], Error>) -> Void) {
        fxPurchase?.getProducts(by: paywall) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self?.cacheManager.storeProducts(products, for: paywall.name)
                    completion(.success(products))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func loadProducts(placementId: String, completion: @escaping (Result<[FXProduct], Error>) -> Void) {
        guard let paywall = cacheManager.getPaywall(for: placementId) else {
            completion(.failure(PaywallError.paywallNotLoaded))
            return
        }
        
        loadProducts(paywall: paywall, completion: completion)
    }
    
    func purchaseProduct(placementId: String, product: FXProduct, paywallName: String? = nil, completion: @escaping (Result<FXPurchaseInfo, Error>) -> Void) {
        DispatchQueue.main.async {
            if let topViewController = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
                self.showLoadingIndicator(on: topViewController)
            }
        }
        
        fxPurchase?.startPurchase(with: product) { result in
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                
                switch result {
                case .success(let purchaseInfo):
                    if let premium = purchaseInfo.info["premium"] as? Bool, premium == true {
                        SessionDataManager.shared.isPremium = true
                        if let paywallName = paywallName {
                            AnalyticsManager.shared.fxAnalytics.send(event: "paywall_purchaseProcess_success", properties: [
                                "paywall": paywallName,
                                "placement": placementId,
                                "product": product.productId
                            ])
                        }
                        completion(.success(purchaseInfo))
                    } else {
                        if let paywallName = paywallName {
                            AnalyticsManager.shared.fxAnalytics.send(event: "paywall_purchaseProcess_failed", properties: [
                                "paywall": paywallName,
                                "placement": placementId,
                                "product": product.productId
                            ])
                        }
                        let error = NSError(domain: "PurchaseError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Purchase was cancelled or failed"])
                        completion(.failure(error))
                    }
                case .failure(let error):
                    if let paywallName = paywallName {
                        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_purchaseProcess_failed", properties: [
                            "paywall": paywallName,
                            "placement": placementId,
                            "product": product.productId
                        ])
                    }
                    completion(.failure(error))
                }
            }
        }
    }
    
    func restorePurchases(completion: @escaping (Result<FXPurchaseInfo, Error>) -> Void) {
        fxPurchase?.restore { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let purchaseInfo):
                    if let premium = purchaseInfo.info["premium"] as? Bool, premium == true {
                        SessionDataManager.shared.isPremium = true
                    }
                    completion(.success(purchaseInfo))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getPaywall(placementId: String) -> FXPaywall? {
        return cacheManager.getPaywall(for: placementId)
    }
    
    func getProducts(placementId: String) -> [FXProduct]? {
        return cacheManager.getProducts(for: placementId)
    }
    
    func getPaywallData(placementId: String) -> [String: Any]? {
        return cacheManager.getPaywallData(for: placementId)
    }
    
    func clearCache(placementId: String) {
        cacheManager.clearCache(for: placementId)
    }
    
    func clearAllCache() {
        cacheManager.clearAllCache()
    }
    
    private var loadingIndicator: UIActivityIndicatorView?
    private var loadingOverlay: UIView?
    
    private func showLoadingIndicator(on viewController: UIViewController) {
        hideLoadingIndicator()
        
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isUserInteractionEnabled = true
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        indicator.layer.cornerRadius = 10
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.addSubview(overlay)
        overlay.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            
            indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 80),
            indicator.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        indicator.startAnimating()
        loadingIndicator = indicator
        loadingOverlay = overlay
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingOverlay?.removeFromSuperview()
        loadingIndicator = nil
        loadingOverlay = nil
    }
}

enum PaywallError: Error {
    case paywallNotLoaded
    case productsNotLoaded
    case invalidPlacementId
    
    var localizedDescription: String {
        switch self {
        case .paywallNotLoaded:
            return "Paywall not loaded for this placement"
        case .productsNotLoaded:
            return "Products not loaded for this placement"
        case .invalidPlacementId:
            return "Invalid placement ID"
        }
    }
}

enum PaywallPlacement: String, CaseIterable {
    case onboarding = "onboarding"
    case settings = "settings"
    case remote = "remote"
    case main = "main"
    case onclose = "onclose"
    
    var displayName: String {
        switch self {
        case .onboarding:
            return "Onboarding Paywall"
        case .settings:
            return "Settings Paywall"
        case .remote:
            return "Remote Paywall"
        case .main:
            return "Main Paywall"
        case .onclose:
            return "On Close Paywall"
        }
    }
}
