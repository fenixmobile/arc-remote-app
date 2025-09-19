//
//  PaywallManager.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import UIKit
import FXFramework

class PaywallManager {
    static let shared = PaywallManager()
    
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
            return Paywall3ViewController(placementId: placementId)
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
