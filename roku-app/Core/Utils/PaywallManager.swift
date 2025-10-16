//
//  PaywallManager.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
//

import UIKit
import FXFramework

class PaywallManager {
    static let shared = PaywallManager()
    
    private var parentPlacementId: String?
    
    private init() {}
    
    func showPaywall(placement: PaywallPlacement, from viewController: UIViewController, completion: ((Result<Void, Error>) -> Void)? = nil) {
        print("PaywallManager: Showing paywall for placement: \(placement.rawValue)")
        print("PaywallManager: From viewController: \(type(of: viewController))")
        showDynamicPaywall(placementId: placement.rawValue, from: viewController) {
            completion?(.success(()))
        }
    }
    
    func showPaywallWithPlacementId(_ placementId: String, from viewController: UIViewController, completion: (() -> Void)? = nil) {
        let paywallVC = createPaywallViewController(for: placementId)
        
        paywallVC.modalPresentationStyle = .overFullScreen
        paywallVC.modalTransitionStyle = .crossDissolve
        
        viewController.present(paywallVC, animated: true) {
            completion?()
        }
    }
    
    func showDynamicPaywall(placementId: String, from viewController: UIViewController, completion: (() -> Void)? = nil) {
        print("PaywallManager: showDynamicPaywall called with placementId: \(placementId)")
        print("PaywallManager: From viewController: \(type(of: viewController))")
        
        if placementId != "onclose" {
            parentPlacementId = placementId
        }
        
        if placementId == "main" {
            UserDefaultsManager.shared.markMainPaywallShown()
        } else if placementId == "onclose" {
            UserDefaultsManager.shared.markOnboardingPaywallSeen()
        }
        
        PaywallHelper.shared.loadPaywall(placementId: placementId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paywall):
                    print("PaywallManager: Paywall loaded successfully: \(paywall.name)")
                    
                    PaywallHelper.shared.loadProducts(paywall: paywall) { [weak self] productsResult in
                        DispatchQueue.main.async {
                            switch productsResult {
                            case .success:
                                print("PaywallManager: Products loaded successfully")
                                let paywallVC = self?.createDynamicPaywallViewController(for: paywall, placementId: placementId)
                                paywallVC?.modalPresentationStyle = .overFullScreen
                                paywallVC?.modalTransitionStyle = .crossDissolve
                                
                                if let paywallVC = paywallVC {
                                    print("PaywallManager: Presenting paywall: \(type(of: paywallVC))")
                                    viewController.present(paywallVC, animated: true) {
                                        completion?()
                                    }
                                } else {
                                    print("PaywallManager: Failed to create paywall view controller")
                                }
                            case .failure(let error):
                                print("PaywallManager: Products yüklenemedi: \(error)")
                                let fallbackVC = Paywall1ViewController(placementId: placementId)
                                fallbackVC.modalPresentationStyle = .overFullScreen
                                fallbackVC.modalTransitionStyle = .crossDissolve
                                viewController.present(fallbackVC, animated: true) {
                                    completion?()
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("PaywallManager: Dynamic paywall yüklenemedi: \(error)")
                    let fallbackVC = Paywall1ViewController(placementId: placementId)
                    fallbackVC.modalPresentationStyle = .overFullScreen
                    fallbackVC.modalTransitionStyle = .crossDissolve
                    viewController.present(fallbackVC, animated: true) {
                        completion?()
                    }
                }
            }
        }
    }
    
    private func createDynamicPaywallViewController(for paywall: FXPaywall, placementId: String) -> UIViewController? {
        let paywallName = paywall.name.lowercased()
        let isOnClosePaywall = placementId == PaywallPlacement.onclose.rawValue
        
        if paywallName.contains("paywall1") {
            return Paywall1ViewController(placementId: placementId, isOnClosePaywall: isOnClosePaywall)
        } else if paywallName.contains("paywall2") {
            return Paywall2ViewController(placementId: placementId, isOnClosePaywall: isOnClosePaywall)
        } else if paywallName.contains("paywall3") {
            return Paywall3ViewController(placementId: placementId, isOnClosePaywall: isOnClosePaywall)
        } else if paywallName.contains("paywall4") {
            return Paywall2ViewController(placementId: placementId, isOnClosePaywall: isOnClosePaywall)
        } else {
            return Paywall1ViewController(placementId: placementId, isOnClosePaywall: isOnClosePaywall)
        }
    }
    
    private func createPaywallViewController(for placement: PaywallPlacement) -> UIViewController {
        switch placement {
        case .onboarding:
            return Paywall1ViewController(placementId: placement.rawValue)
        case .settings:
            return Paywall2ViewController(placementId: placement.rawValue)
        case .remote:
            return Paywall3ViewController(placementId: placement.rawValue)
        case .premium:
            return Paywall1ViewController(placementId: placement.rawValue)
        case .main:
            return Paywall2ViewController(placementId: placement.rawValue)
        case .onclose:
            return Paywall2ViewController(placementId: placement.rawValue, isOnClosePaywall: true)
        }
    }
    
    private func createPaywallViewController(for placementId: String) -> UIViewController {
        switch placementId {
        case PaywallPlacement.onboarding.rawValue:
            return Paywall1ViewController(placementId: placementId)
        case PaywallPlacement.settings.rawValue:
            return Paywall2ViewController(placementId: placementId)
        case PaywallPlacement.remote.rawValue:
            return Paywall3ViewController(placementId: placementId)
        case PaywallPlacement.premium.rawValue:
            return Paywall1ViewController(placementId: placementId)
        case PaywallPlacement.main.rawValue:
            return Paywall2ViewController(placementId: placementId)
        case PaywallPlacement.onclose.rawValue:
            return Paywall2ViewController(placementId: placementId, isOnClosePaywall: true)
        default:
            return Paywall1ViewController(placementId: placementId)
        }
    }
    
    func showClaimOfferModal(from viewController: UIViewController, paywall: FXPaywall, placementId: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: "Are you sure you want to skip the opportunity for a 3 day free trial?",
            message: "Enjoy a completely free 3-day trial. If you're not satisfied, you can cancel any time.",
            preferredStyle: .alert
        )
        
        let notNowAction = UIAlertAction(title: "Not now", style: .default) { _ in
            print("PaywallManager: User tapped 'Not now' - closing all paywalls and navigating to main")
            self.dismissAllPaywallsAndNavigateToMain(from: viewController, completion: completion)
        }
        
        let claimOfferAction = UIAlertAction(title: "Claim Offer", style: .default) { _ in
            print("PaywallManager: User tapped 'Claim Offer' - attempting purchase")
            self.handleClaimOfferPurchase(from: viewController, paywall: paywall, placementId: placementId, completion: completion)
        }
        
        alert.addAction(notNowAction)
        alert.addAction(claimOfferAction)
        
        viewController.present(alert, animated: true)
    }
    
    func handleClaimOfferPurchase(from viewController: UIViewController, paywall: FXPaywall, placementId: String, completion: (() -> Void)? = nil) {
        guard let firstProduct = paywall.products?.first else {
            print("PaywallManager: No products available for purchase")
            return
        }
        
        PaywallHelper.shared.purchaseProduct(placementId: placementId, product: firstProduct) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("PaywallManager: Purchase successful")
                    SessionDataManager.shared.isPremium = true
                    self.dismissAllPaywallsAndNavigateToMain(from: viewController, completion: completion)
                case .failure(let error):
                    print("PaywallManager: Purchase failed: \(error)")
                    
                    if let remoteConfig = paywall.remoteConfig,
                       let displayOnClosePaywallFailure = remoteConfig["display_onClose_paywall_failure"] as? Bool,
                       displayOnClosePaywallFailure {
                        print("PaywallManager: display_onClose_paywall_failure is true, showing onClose paywall")
                        self.showOnClosePaywallAfterFailure(from: viewController, completion: completion)
                    } else {
                        self.dismissAllPaywallsAndNavigateToMain(from: viewController, completion: completion)
                    }
                }
            }
        }
    }
    
    func showOnClosePaywall(from viewController: UIViewController, completion: ((Result<Void, Error>) -> Void)? = nil) {
        print("PaywallManager: Showing onClose paywall with parentPlacementId: \(parentPlacementId ?? "nil")")
        print("PaywallManager: Current parentPlacementId before onclose: \(parentPlacementId ?? "nil")")
        
        PaywallHelper.shared.loadPaywall(placementId: "onclose") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paywall):
                    print("PaywallManager: OnClose paywall loaded successfully: \(paywall.name)")
                    
                    PaywallHelper.shared.loadProducts(paywall: paywall) { [weak self] productsResult in
                        DispatchQueue.main.async {
                            switch productsResult {
                            case .success:
                                print("PaywallManager: Products loaded successfully")
                                let paywallVC = self?.createDynamicPaywallViewController(for: paywall, placementId: "onclose")
                                paywallVC?.modalPresentationStyle = .overFullScreen
                                paywallVC?.modalTransitionStyle = .crossDissolve
                                
                                if let paywallVC = paywallVC {
                                    print("PaywallManager: Presenting onClose paywall: \(type(of: paywallVC))")
                                    viewController.present(paywallVC, animated: true) {
                                        completion?(.success(()))
                                    }
                                } else {
                                    print("PaywallManager: Failed to create onClose paywall view controller")
                                    completion?(.failure(NSError(domain: "PaywallManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create paywall view controller"])))
                                }
                            case .failure(let error):
                                print("PaywallManager: Products yüklenemedi: \(error)")
                                let fallbackVC = Paywall1ViewController(placementId: "onclose")
                                fallbackVC.modalPresentationStyle = .overFullScreen
                                fallbackVC.modalTransitionStyle = .crossDissolve
                                viewController.present(fallbackVC, animated: true) {
                                    completion?(.success(()))
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("PaywallManager: OnClose paywall yüklenemedi: \(error)")
                    let fallbackVC = Paywall1ViewController(placementId: "onclose")
                    fallbackVC.modalPresentationStyle = .overFullScreen
                    fallbackVC.modalTransitionStyle = .crossDissolve
                    viewController.present(fallbackVC, animated: true) {
                        completion?(.success(()))
                    }
                }
            }
        }
    }
    
    func showOnClosePaywallAfterFailure(from viewController: UIViewController, completion: (() -> Void)? = nil) {
        print("PaywallManager: Showing onClose paywall after purchase failure with parentPlacementId: \(parentPlacementId ?? "nil")")
        
        PaywallHelper.shared.loadPaywall(placementId: "onclose") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paywall):
                    print("PaywallManager: OnClose paywall loaded successfully: \(paywall.name)")
                    
                    PaywallHelper.shared.loadProducts(paywall: paywall) { [weak self] productsResult in
                        DispatchQueue.main.async {
                            switch productsResult {
                            case .success:
                                print("PaywallManager: Products loaded successfully")
                                let paywallVC = self?.createDynamicPaywallViewController(for: paywall, placementId: "onclose")
                                paywallVC?.modalPresentationStyle = .overFullScreen
                                paywallVC?.modalTransitionStyle = .crossDissolve
                                
                                if let paywallVC = paywallVC {
                                    print("PaywallManager: Presenting onClose paywall: \(type(of: paywallVC))")
                                    viewController.present(paywallVC, animated: true) {
                                        completion?()
                                    }
                                } else {
                                    print("PaywallManager: Failed to create onClose paywall view controller")
                                }
                            case .failure(let error):
                                print("PaywallManager: Products yüklenemedi: \(error)")
                                let fallbackVC = Paywall1ViewController(placementId: "onclose")
                                fallbackVC.modalPresentationStyle = .overFullScreen
                                fallbackVC.modalTransitionStyle = .crossDissolve
                                viewController.present(fallbackVC, animated: true) {
                                    completion?()
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("PaywallManager: OnClose paywall yüklenemedi: \(error)")
                    let fallbackVC = Paywall1ViewController(placementId: "onclose")
                    fallbackVC.modalPresentationStyle = .overFullScreen
                    fallbackVC.modalTransitionStyle = .crossDissolve
                    viewController.present(fallbackVC, animated: true) {
                        completion?()
                    }
                }
            }
        }
    }
    
    func dismissAllPaywallsAndNavigateToMain(from viewController: UIViewController, completion: (() -> Void)? = nil) {
        var currentVC = viewController
        
        while let presentingVC = currentVC.presentingViewController {
            currentVC = presentingVC
        }
        
        let shouldNavigateToMain = parentPlacementId == "onboarding"
        print("PaywallManager: dismissAllPaywallsAndNavigateToMain called")
        print("PaywallManager: parentPlacementId: \(parentPlacementId ?? "nil")")
        print("PaywallManager: shouldNavigateToMain: \(shouldNavigateToMain)")
        print("PaywallManager: currentVC: \(currentVC)")
        print("PaywallManager: from viewController: \(type(of: viewController))")
        
        currentVC.dismiss(animated: true) {
            if shouldNavigateToMain {
                print("PaywallManager: Navigating to main app")
                self.navigateToMainApp(from: currentVC)
            } else {
                print("PaywallManager: Not navigating to main app")
            }
            completion?()
        }
    }
    
    func navigateToMainApp(from viewController: UIViewController) {
        guard let window = viewController.view.window else { return }
        
        let mainTabBarController = MainTabBarController()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = mainTabBarController
        }) { _ in
            window.makeKeyAndVisible()
        }
    }
}
