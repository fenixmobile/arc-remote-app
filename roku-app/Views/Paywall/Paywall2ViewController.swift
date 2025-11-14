//
//  Paywall2ViewController.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
//

import Foundation
import UIKit
import FXFramework
import WebKit

class Paywall2ViewController: UIViewController {
    
    //MARK: - Properties
    
    var fxPaywall: FXPaywall?
    var placementId: String
    var isOnClosePaywall: Bool = false
    var products: [Product] = []
    
    init(placementId: String = "settings", isOnClosePaywall: Bool = false) {
        self.placementId = placementId
        self.isOnClosePaywall = isOnClosePaywall
        print("Paywall2ViewController: init - placementId = \(placementId), isOnClosePaywall = \(isOnClosePaywall)")
        super.init(nibName: nil, bundle: nil)
        loadPaywallData()
    }
    
    private func loadPaywallData() {
        PaywallHelper.shared.loadPaywall(placementId: placementId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paywall):
                    self?.fxPaywall = paywall
                    PaywallHelper.shared.loadProducts(paywall: paywall) { [weak self] productsResult in
                        DispatchQueue.main.async {
                            switch productsResult {
                            case .success:
                                print("Paywall2ViewController: Products loaded successfully")
                                self?.loadPaywallConfiguration()
                            case .failure(let error):
                                print("Paywall2ViewController: Failed to load products: \(error)")
                                self?.loadPaywallConfiguration()
                            }
                        }
                    }
                case .failure(let error):
                    print("Paywall2ViewController: Failed to load paywall: \(error)")
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        self.placementId = "settings"
        super.init(coder: coder)
    }
    
    
    //MARK: - UI Elements
    
    lazy var imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = UIImage(named: "howto5")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.2
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Poppins-Bold", size: 26)
        label.textColor = UIColor(named: "title")
        label.numberOfLines = 0
        label.text = ""
        label.textAlignment = .center
        label.alpha = 0.2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Poppins-Light", size: 16)
        label.textColor = UIColor(named: "subtitle")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.alpha = 0.2
        return label
    }()
    
    lazy var continueButton: UIButton = {
        let button: UIButton = .init()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "button")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button: UIButton = .init()
        button.accessibilityIdentifier = "PageCloseButton"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        let boldConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: boldConfig), for: .normal)
        button.tintColor = UIColor.white
        button.accessibilityIdentifier = "PaywallCloseButton"
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var pCntrl: UIPageControl = {
        let pageController: UIPageControl = .init()
        pageController.translatesAutoresizingMaskIntoConstraints = false
        pageController.numberOfPages = 4
        pageController.currentPage = 0
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.currentPageIndicatorTintColor = UIColor(named: "button")
        return pageController
    }()
    
    lazy var restoreLabel: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(named: "subtitle"), for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 1
        button.setTitle("Restore", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Light", size: 12)
        button.addTarget(self, action: #selector(restoreLabelTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var lineView2: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "subtitle")
        return view
    }()
    
    lazy var termOfUseLabel: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(named: "subtitle"), for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 1
        button.setTitle("Terms of Use", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Light", size: 12)
        button.addTarget(self, action: #selector(termOfUseLabelTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var lineView: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "subtitle")
        return view
    }()
    
    lazy var privacyPolicyLabel: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(named: "subtitle"), for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 1
        button.setTitle("Privacy Policy", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Light", size: 12)
        button.addTarget(self, action: #selector(privacyPolicyLabelTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var loadingActivityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView: UIActivityIndicatorView = .init()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.color = .white
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        fadeInElements()
        
        print("Paywall2ViewController viewDidLoad - fxPaywall: \(fxPaywall != nil)")
    }
    
    private func loadPaywallConfiguration() {
        guard let paywall = fxPaywall,
              let remoteConfig = paywall.remoteConfig else {
            setDefaultValues()
            return
        }
        
        if let closeButtonColor = remoteConfig["close_button_color"] as? String {
            closeButton.tintColor = UIColor(hexString: closeButtonColor)
        }
        
        if let title = remoteConfig["title"] as? String {
            titleLabel.text = title
        }
        
        if let productDescription = remoteConfig["product_description"] as? String {
            print("Remote config product_description: \(productDescription)")
            if let fxProduct = fxPaywall?.products?.first {
                let price = fxProduct.localizedPrice ?? ""
                print("FXProduct localizedPrice: \(price)")
                descriptionLabel.text = productDescription.replacingOccurrences(of: "#price#", with: price)
                print("Final description text: \(descriptionLabel.text ?? "")")
            } else {
                print("No FXProduct found")
                descriptionLabel.text = productDescription
            }
        } else {
            print("No product_description in remote config")
        }
        
        if let purchaseButtonTitle = remoteConfig["purchase_button_title"] as? String {
            continueButton.setTitle(purchaseButtonTitle, for: .normal)
        }
    }
    
    private func setDefaultValues() {
        closeButton.tintColor = UIColor.white
        titleLabel.text = "Get full access to universal TV REMOTE"
        
        let defaultDescription = "Try 3 days for free, then #price#/week Auto-renewable. Cancel Anytime."
        if let fxProduct = fxPaywall?.products?.first {
            let price = fxProduct.localizedPrice ?? ""
            print("setDefaultValues - FXProduct localizedPrice: \(price)")
            descriptionLabel.text = defaultDescription.replacingOccurrences(of: "#price#", with: price)
        } else {
            print("setDefaultValues - No FXProduct found")
            descriptionLabel.text = defaultDescription
        }
        
        continueButton.setTitle("Continue", for: .normal)
        print("setDefaultValues called - final description: \(descriptionLabel.text ?? "")")
    }
    
    
    //MARK: - Functions
    private func setupViews() {
        view.backgroundColor = UIColor(named: "primary")
        view.addSubview(imageView)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(continueButton)
        view.addSubview(restoreLabel)
        view.addSubview(lineView2)
        view.addSubview(termOfUseLabel)
        view.addSubview(lineView)
        view.addSubview(privacyPolicyLabel)
        view.addSubview(loadingActivityIndicatorView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.69),
            
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -60),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(lessThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.15),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            descriptionLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 340),
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.1),
            descriptionLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -8),
            
            continueButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 350),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: termOfUseLabel.topAnchor, constant: -8),
            
            lineView.widthAnchor.constraint(equalToConstant: 1),
            lineView.heightAnchor.constraint(equalToConstant: 18),
            lineView.leadingAnchor.constraint(equalTo: continueButton.leadingAnchor, constant: 100),
            lineView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
            termOfUseLabel.leadingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: 8),
            termOfUseLabel.centerYAnchor.constraint(equalTo: lineView.centerYAnchor),
            
            lineView2.widthAnchor.constraint(equalToConstant: 1),
            lineView2.heightAnchor.constraint(equalToConstant: 18),
            lineView2.centerYAnchor.constraint(equalTo: lineView.centerYAnchor),
            lineView2.leadingAnchor.constraint(equalTo: termOfUseLabel.trailingAnchor, constant: 8),
            
            restoreLabel.centerYAnchor.constraint(equalTo: termOfUseLabel.centerYAnchor),
            restoreLabel.trailingAnchor.constraint(equalTo: lineView.leadingAnchor, constant: -8),
            
            privacyPolicyLabel.centerYAnchor.constraint(equalTo: termOfUseLabel.centerYAnchor),
            privacyPolicyLabel.leadingAnchor.constraint(equalTo: lineView2.trailingAnchor, constant: 8),
            
            loadingActivityIndicatorView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            loadingActivityIndicatorView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            loadingActivityIndicatorView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            loadingActivityIndicatorView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }
    
    func fadeInElements() {
        UIView.animate(withDuration: 1.0) {
            self.imageView.alpha = 1
            self.titleLabel.alpha = 1
            self.descriptionLabel.alpha = 1
            self.continueButton.alpha = 1
        }
    }
    
    func showWebViewContentPage(title: String, contentURL: String) {
        guard let url = URL(string: contentURL) else { return }
        let webViewController = WebViewController(url: url, title: title)
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.modalPresentationStyle = .pageSheet
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
    
    
    //MARK: - OBJC Functions
    
    @objc func purchaseButtonTapped() {
        PaywallManager.shared.handlePurchaseButtonTapped(
            from: self,
            placementId: placementId,
            fxPaywall: fxPaywall!,
            products: products
        )
    }
    
    private func startPurchase(product: FXProduct, paywall: FXPaywall) {
        loadingActivityIndicatorView.startAnimating()
        loadingActivityIndicatorView.isHidden = false
        
        continueButton.isEnabled = false
        closeButton.isEnabled = false
        
        PaywallHelper.shared.purchaseProduct(placementId: placementId, product: product, paywallName: paywall.name) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingActivityIndicatorView.stopAnimating()
                self?.loadingActivityIndicatorView.isHidden = true
                self?.continueButton.isEnabled = true
                self?.closeButton.isEnabled = true
                
                switch result {
                case .success(let purchaseInfo):
                    print("Paywall2ViewController: Purchase successful: \(purchaseInfo)")
                    self?.handlePurchaseSuccess()
                case .failure(let error):
                    print("Paywall2ViewController: Purchase failed: \(error)")
                    self?.handlePurchaseFailure(error: error)
                }
            }
        }
    }
    
    private func handlePurchaseSuccess() {
        if placementId == "main" {
            dismiss(animated: true, completion: nil)
        } else {
            guard let window = view.window else { return }
            
            dismiss(animated: true) {
                let mainTabBarController = MainTabBarController()
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = mainTabBarController
                }) { _ in
                    //window.makeKeyAndVisible()
                }
            }
        }
    }
    
    private func handlePurchaseFailure(error: Error) {
        guard let paywall = fxPaywall,
              let remoteConfig = paywall.remoteConfig,
              let displayOnClosePaywallFailure = remoteConfig["display_onClose_paywall_failure"] as? Bool else {
            showPurchaseFailedAlert()
            return
        }
        
        if displayOnClosePaywallFailure && !isOnClosePaywall {
            showOnClosePaywallAfterFailure()
        } else {
            showPurchaseFailedAlert()
        }
    }
    
    private func showPurchaseFailedAlert() {
        let alert = UIAlertController(
            title: "Purchase Failed",
            message: "Unable to complete purchase. Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showOnClosePaywallAfterFailure() {
        PaywallManager.shared.showOnClosePaywallAfterFailure(from: self)
    }
    
    @objc func closeButtonTapped() {
        if placementId == "onclose" {
            AnalyticsManager.shared.fxAnalytics.send(event: "onclose_purchase_close")
        } else {
            AnalyticsManager.shared.fxAnalytics.send(event: "paywall_close")
        }

        print("Paywall2ViewController: Close button tapped")
        
        guard let remoteConfig = fxPaywall?.remoteConfig else {
            handleNormalClose()
            return
        }
        
        let displayClaimOfferPrompt = remoteConfig["display_claimOffer_prompt"] as? Bool ?? false
        let displayOnClosePaywall = remoteConfig["display_onClose_paywall"] as? Bool ?? false
        
        if displayClaimOfferPrompt {
            print("Paywall2ViewController: Showing claim offer modal")
            showClaimOfferModal()
        } else if displayOnClosePaywall && !isOnClosePaywall {
            print("Paywall2ViewController: Showing onclose paywall")
            showOnClosePaywall()
        } else {
            handleNormalClose()
        }
    }
    
    private func showClaimOfferModal() {
        let alert = UIAlertController(
            title: "Are you sure you want to skip the opportunity for a 3 day free trial?",
            message: "Enjoy a completely free 3-day trial. If you're not satisfied, you can cancel any time.",
            preferredStyle: .alert
        )
        
        let notNowAction = UIAlertAction(title: "Not now", style: .default) { _ in
            print("Paywall2ViewController: User tapped 'Not now' - closing all paywalls")
            AnalyticsManager.shared.fxAnalytics.send(event: "offer_popup_not_now")
            self.handleNormalClose()
        }
        
        let claimOfferAction = UIAlertAction(title: "Claim Offer", style: .default) { _ in
            print("Paywall2ViewController: User tapped 'Claim Offer' - attempting purchase")
            AnalyticsManager.shared.fxAnalytics.send(event: "offer_popup_claim_offer")
            self.handleClaimOfferPurchase()
        }
        
        alert.addAction(notNowAction)
        alert.addAction(claimOfferAction)
        
        present(alert, animated: true)
    }
    
    private func handleClaimOfferPurchase() {
        guard let fxPaywall = fxPaywall,
              let fxProduct = fxPaywall.products?.first else { return }
        
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_purchaseProcess_start", properties: [
            "paywall": fxPaywall.name,
            "placement": placementId,
            "product": fxProduct.productId
        ])
        
        loadingActivityIndicatorView.startAnimating()
        loadingActivityIndicatorView.isHidden = false
        
        continueButton.isEnabled = false
        closeButton.isEnabled = false
        
        PaywallHelper.shared.purchaseProduct(placementId: placementId, product: fxProduct, paywallName: fxPaywall.name) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingActivityIndicatorView.stopAnimating()
                self?.loadingActivityIndicatorView.isHidden = true
                self?.continueButton.isEnabled = true
                self?.closeButton.isEnabled = true
                
                switch result {
                case .success(let purchaseInfo):
                    print("Paywall2ViewController: Claim offer purchase successful: \(purchaseInfo)")
                    self?.handleNormalClose()
                case .failure(let error):
                    print("Paywall2ViewController: Claim offer purchase failed: \(error)")
                    
                    if let remoteConfig = self?.fxPaywall?.remoteConfig,
                       let displayOnClosePaywallFailure = remoteConfig["display_onClose_paywall_failure"] as? Bool,
                       displayOnClosePaywallFailure {
                        print("Paywall2ViewController: display_onClose_paywall_failure is true, showing onClose paywall")
                        self?.showOnClosePaywallAfterFailure()
                    } else {
                        self?.handleNormalClose()
                    }
                }
            }
        }
    }
    
    private func showOnClosePaywall() {
        print("Paywall2ViewController: Showing onclose paywall")
        
        PaywallManager.shared.showOnClosePaywall(from: self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Paywall2ViewController: Onclose paywall shown successfully")
                case .failure(let error):
                    print("Paywall2ViewController: Failed to show onclose paywall: \(error)")
                }
            }
        }
    }
    
    private func handleNormalClose() {
        if placementId == "onboarding" || placementId == "onclose" {
            PaywallManager.shared.dismissAllPaywallsAndNavigateToMain(from: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func navigateToMainPage() {
        PaywallManager.shared.dismissAllPaywallsAndNavigateToMain(from: self)
    }
    
    @objc func termOfUseLabelTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_terms_tap")

        showWebViewContentPage(title: "Terms of Use",
                               contentURL: Constants.URLs.termsOfUse)
    }
    
    @objc func privacyPolicyLabelTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_privacy_tap")

        showWebViewContentPage(title: "Privacy Policy",
                               contentURL: Constants.URLs.privacyPolicy)
    }
    
    @objc func restoreLabelTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_restore")

        loadingActivityIndicatorView.isHidden = false
        loadingActivityIndicatorView.startAnimating()
        
        continueButton.isEnabled = false
        closeButton.isEnabled = false
        
        PaywallHelper.shared.restorePurchases { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingActivityIndicatorView.stopAnimating()
                self?.loadingActivityIndicatorView.isHidden = true
                self?.continueButton.isEnabled = true
                self?.closeButton.isEnabled = true
                
                switch result {
                case .success(let purchaseInfo):
                    print("Paywall2ViewController: Restore successful: \(purchaseInfo)")
                    self?.handlePurchaseSuccess()
                case .failure(let error):
                    print("Paywall2ViewController: Restore failed: \(error)")
                    self?.handleRestoreFailure(error: error)
                }
            }
        }
    }
    
    private func handleRestoreFailure(error: Error) {
        let alert = UIAlertController(title: "Restore Failed", 
                                    message: "No previous purchases found to restore.", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func nextPage() {
        if let parentViewController = parent as? PageViewController {
            parentViewController.showNextPage()
        } else if let navigationController = navigationController {
            dismiss(animated: true) {
                let tabBarVC = MainTabBarController()
                navigationController.setViewControllers([tabBarVC], animated: false)
            }
        } else {
            dismiss(animated: false) {
                let tabBarVC = MainTabBarController()
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = UINavigationController(rootViewController: tabBarVC)
                    //window.makeKeyAndVisible()
                }
            }
        }
    }
}

