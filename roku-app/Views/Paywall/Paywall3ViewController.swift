//
//  Paywall3ViewController.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
//

import UIKit
import FXFramework

class Paywall3ViewController: UIViewController {
    
    //MARK: - Properties
    
    var fromOnboarding: Bool = false
    var completion: (()->Void)?
    var fxPaywall: FXPaywall?
    var placementId: String
    var isOnClosePaywall: Bool = false
    
    init(placementId: String = "remote", isOnClosePaywall: Bool = false) {
        self.placementId = placementId
        self.isOnClosePaywall = isOnClosePaywall
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.placementId = "remote"
        super.init(coder: coder)
    }
    
    // MARK: - PaywallNavigationManager Properties
    var displayClaimOfferAlert: Bool = false
    var displayOncloseModal: Bool = false
    var displayOnclosePaywallFailure: Bool = false
    
    //MARK: - UI Elements
    
    lazy var paywall3ModalView: Paywall3ModalView = {
        let view: Paywall3ModalView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placementId = placementId
        return view
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupPurchaseCompletion()
        setupNotifications()
        
        loadPaywallData()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(modalClosed), name: NSNotification.Name("modalClosed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(termsOfUse), name: NSNotification.Name("termsOfUse"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(privacyPolicy), name: NSNotification.Name("privacyPolicy"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restoreLabelTapped), name: NSNotification.Name("restore"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name("ShowAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showOnClosePaywall), name: NSNotification.Name("ShowOnClosePaywall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseCompleted), name: NSNotification.Name("PurchaseCompleted"), object: nil)
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
                                print("Paywall3ViewController: Products loaded successfully")
                                self?.loadPaywallConfiguration()
                            case .failure(let error):
                                print("Paywall3ViewController: Failed to load products: \(error)")
                                self?.loadPaywallConfiguration()
                            }
                        }
                    }
                case .failure(let error):
                    print("Paywall3ViewController: Failed to load paywall: \(error)")
                }
            }
        }
    }
    
    func loadPaywallConfiguration() {
        guard let paywall = fxPaywall,
              let remoteConfig = paywall.remoteConfig else {
            setDefaultValues()
            return
        }
        
        print("Paywall3ViewController: Remote config loaded, updating UI...")
        updateUIWithRemoteConfig(remoteConfig: remoteConfig, fxPaywall: paywall)
    }
    
    private func setDefaultValues() {
        paywall3ModalView.fxPaywall = fxPaywall
        
        DispatchQueue.main.async {
            self.paywall3ModalView.setDefaultValues()
        }
    }
    
    func updateUIWithRemoteConfig(remoteConfig: [String: Any], fxPaywall: FXPaywall) {
        paywall3ModalView.fxPaywall = fxPaywall
        
        DispatchQueue.main.async {
            self.paywall3ModalView.updateUIWithRemoteConfig(remoteConfig: remoteConfig, fxPaywall: fxPaywall)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Functions
    
    private func setupPurchaseCompletion() {
        // Purchase completion handled by Paywall3ModalView
    }
    
    private func setupViews() {
        view.addSubview(paywall3ModalView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            paywall3ModalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paywall3ModalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            paywall3ModalView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.66),
            paywall3ModalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
    
    @objc func termsOfUse() {
        showWebViewContentPage(title: "Terms of Use",
                               contentURL: Constants.URLs.termsOfUse)
    }
    
    @objc func privacyPolicy() {
        showWebViewContentPage(title: "Privacy Policy",
                               contentURL: Constants.URLs.privacyPolicy)
    }
    
    @objc func restoreLabelTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_restore")

        paywall3ModalView.loadingActivityIndicatorView.startAnimating()
        
        PaywallHelper.shared.restorePurchases { [weak self] result in
            DispatchQueue.main.async {
                self?.paywall3ModalView.loadingActivityIndicatorView.stopAnimating()
                self?.paywall3ModalView.loadingActivityIndicatorView.isHidden = true
                
                switch result {
                case .success(let purchaseInfo):
                    print("Paywall3ViewController: Restore successful: \(purchaseInfo)")
                    self?.handlePurchaseCompleted()
                case .failure(let error):
                    print("Paywall3ViewController: Restore failed: \(error)")
                    self?.showRestoreFailureAlert()
                }
            }
        }
    }
    
    private func showRestoreFailureAlert() {
        let alert = UIAlertController(title: "Restore Failed", 
                                    message: "No previous purchases found to restore.", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func modalClosed() {
        paywall3ModalView.loadingActivityIndicatorView.isHidden = true
        paywall3ModalView.loadingActivityIndicatorView.stopAnimating()
        
        guard let remoteConfig = fxPaywall?.remoteConfig else {
            handleNormalClose()
            return
        }
        
        let displayClaimOfferPrompt = remoteConfig["display_claimOffer_prompt"] as? Bool ?? false
        let displayOnClosePaywall = remoteConfig["display_onClose_paywall"] as? Bool ?? false
        
        if displayClaimOfferPrompt {
            print("Paywall3ViewController: Showing claim offer modal")
            showClaimOfferModal()
        } else if displayOnClosePaywall && placementId != "onclose" {
            print("Paywall3ViewController: Showing onclose paywall")
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
            print("Paywall3ViewController: User tapped 'Not now' - closing all paywalls")
            self.handleNormalClose()
        }
        
        let claimOfferAction = UIAlertAction(title: "Claim Offer", style: .default) { _ in
            print("Paywall3ViewController: User tapped 'Claim Offer' - attempting purchase")
            self.handleClaimOfferPurchase()
        }
        
        alert.addAction(notNowAction)
        alert.addAction(claimOfferAction)
        
        present(alert, animated: true)
    }
    
    private func handleClaimOfferPurchase() {
        guard let fxPaywall = fxPaywall,
              let fxProduct = fxPaywall.products?.first else { return }
        
        paywall3ModalView.loadingActivityIndicatorView.startAnimating()
        paywall3ModalView.loadingActivityIndicatorView.isHidden = false
        
        paywall3ModalView.continueButton.isEnabled = false
        paywall3ModalView.closeButton.isEnabled = false
        
        PaywallHelper.shared.purchaseProduct(placementId: placementId, product: fxProduct) { [weak self] result in
            DispatchQueue.main.async {
                self?.paywall3ModalView.loadingActivityIndicatorView.stopAnimating()
                self?.paywall3ModalView.loadingActivityIndicatorView.isHidden = true
                self?.paywall3ModalView.continueButton.isEnabled = true
                self?.paywall3ModalView.closeButton.isEnabled = true
                
                switch result {
                case .success(let purchaseInfo):
                    print("Paywall3ViewController: Claim offer purchase successful: \(purchaseInfo)")
                    SessionDataManager.shared.isPremium = true
                    self?.handleNormalClose()
                case .failure(let error):
                    print("Paywall3ViewController: Claim offer purchase failed: \(error)")
                    
                    if let remoteConfig = self?.fxPaywall?.remoteConfig,
                       let displayOnClosePaywallFailure = remoteConfig["display_onClose_paywall_failure"] as? Bool,
                       displayOnClosePaywallFailure {
                        print("Paywall3ViewController: display_onClose_paywall_failure is true, showing onClose paywall")
                        self?.showOnClosePaywallAfterFailure()
                    } else {
                        self?.handleNormalClose()
                    }
                }
            }
        }
    }
    
    private func showOnClosePaywallAfterFailure() {
        PaywallManager.shared.showOnClosePaywallAfterFailure(from: self)
    }
    
    private func handleNormalClose() {
        print("Paywall3ViewController: Handling normal close for placementId: \(placementId)")
        if placementId == "onboarding" || placementId == "onclose" {
            PaywallManager.shared.dismissAllPaywallsAndNavigateToMain(from: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func showAlert(_ notification: Notification) {
        guard let alert = notification.object as? UIAlertController else { return }
        present(alert, animated: true)
    }
    
    @objc func showOnClosePaywall() {
        PaywallManager.shared.showOnClosePaywall(from: self)
    }
    
    @objc func handlePurchaseCompleted() {
        SessionDataManager.shared.isPremium = true
        
        if placementId == "main" {
            dismiss(animated: true, completion: nil)
        } else {
            PaywallManager.shared.dismissAllPaywallsAndNavigateToMain(from: self)
        }
    }
    
    private func navigateToMainPage() {
        PaywallManager.shared.dismissAllPaywallsAndNavigateToMain(from: self)
    }
}
