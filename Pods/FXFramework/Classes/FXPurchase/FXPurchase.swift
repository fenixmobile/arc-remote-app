//
//  FXPurchase.swift
//
//
//  Created by Savaş Salihoğlu on 6.10.2023.
//

import Foundation

public enum FXPurchaseError: Error {
    case receiptURLIsEmpty
    case receiptDataDidNotLoaded
    case receiptDataIsEmpty
    
    case paywallNotFound
    case productsNotFound
    case error(String)
    case any(Error)
}

public protocol FXPurchase {
    
    typealias fxPurchaseResultCompletion = (Result<FXPurchaseInfo, Error>) -> Void
    typealias fxPaywallCompletion = (Result<FXPaywall, Error>) -> Void
    typealias fxProductsCompletion = (Result<[FXProduct], Error>) -> Void
    typealias fxPurchaseErrorCompletion = (FXPurchaseError?) -> Void
    
    //var config: FXPurchaseConfig { get }
    func getPaywall(by identifier: String,
                    completion: @escaping fxPaywallCompletion)
    func getProducts(by paywall: FXPaywall?, completion: @escaping fxProductsCompletion)
    
    func startPurchase(with product: FXProduct, completion: @escaping fxPurchaseResultCompletion)
    func restore(completion: @escaping fxPurchaseResultCompletion)
    func getPurchaseInfo(completion: @escaping fxPurchaseResultCompletion)
    
    func getReceipt() -> Result<Data, FXPurchaseError>
    
    func logShowPaywall(_ paywall: FXPaywall, _ completion: fxPurchaseErrorCompletion?)
    func setExternalUserId(_ externalUserId: String, _ completion: fxPurchaseErrorCompletion?)
}

extension FXPurchase {
    
    public func getReceipt() -> Result<Data, FXPurchaseError> {
        guard let url = Bundle.main.appStoreReceiptURL else {
            FXLog.error("SKReceiptManager: Receipt URL is nil.")
            return .failure(FXPurchaseError.receiptURLIsEmpty)
        }
        
        var data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            FXLog.error("SKReceiptManager: Receipt Data did not loaded. \(error)")
            return .failure(FXPurchaseError.receiptDataDidNotLoaded)
        }
        
        if data.isEmpty {
            FXLog.error("SKReceiptManager: Receipt Data is empty")
            return .failure(FXPurchaseError.receiptDataIsEmpty)
        }
        
        FXLog.verbose("SKReceiptManager: Loaded receipt")
        return .success(data)
    }
    
}
