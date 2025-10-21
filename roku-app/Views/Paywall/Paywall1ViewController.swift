//
//  Paywall1ViewController.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
//

import UIKit
import FXFramework
import WebKit
import StoreKit

class Paywall1ViewController: UIViewController, WKNavigationDelegate {
    
    //MARK: - Properties
    
    var features: [PaywallFeature] = []
    var products: [Product] = []
    var fxPaywall: FXPaywall?
    var placementId: String
    var isOnClosePaywall: Bool = false
    
    init(placementId: String = "onboarding", isOnClosePaywall: Bool = false) {
        self.placementId = placementId
        self.isOnClosePaywall = isOnClosePaywall
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.placementId = "onboarding"
        super.init(coder: coder)
    }
    
    
    //MARK: - UI Elements
    
    lazy var imageView: UIImageView = Paywall1UIFactory.createImageView()
    
    lazy var InAppTitle: UILabel = Paywall1UIFactory.createTitleLabel()
    
    lazy var tableView: UITableView = {
        let tableView = Paywall1UIFactory.createTableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    lazy var startFreeTrialButton: UIButton = {
        let button = Paywall1UIFactory.createPurchaseButton()
        button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = Paywall1UIFactory.createCloseButton()
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = Paywall1UIFactory.createCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var restoreLabel: UIButton = {
        let button = Paywall1UIFactory.createRestoreButton()
        button.addTarget(self, action: #selector(restoreLabelTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var lineView2: UIView = Paywall1UIFactory.createSeparatorLine()
    
    lazy var termOfUseLabel: UIButton = {
        let button = Paywall1UIFactory.createTermsButton()
        button.addTarget(self, action: #selector(termOfUseLabelTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var lineView: UIView = Paywall1UIFactory.createSeparatorLine()
    
    lazy var privacyPolicyLabel: UIButton = {
        let button = Paywall1UIFactory.createPrivacyButton()
        button.addTarget(self, action: #selector(privacyPolicyLabelTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Paywall1UIFactory.createLoadingIndicator()
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        
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
                                print("Paywall1ViewController: Products loaded successfully")
                                self?.loadPaywallConfiguration()
                            case .failure(let error):
                                print("Paywall1ViewController: Failed to load products: \(error)")
                                self?.loadPaywallConfiguration()
                            }
                        }
                    }
                case .failure(let error):
                    print("Paywall1ViewController: Failed to load paywall: \(error)")
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
        
        print("Paywall1ViewController: Remote config loaded, updating UI...")
        updateUIWithRemoteConfig(remoteConfig: remoteConfig, fxPaywall: paywall)
    }
    
    private func setDefaultValues() {
        InAppTitle.text = "Get full access to universal TV REMOTE"
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    func updateUIWithRemoteConfig(remoteConfig: [String: Any], fxPaywall: FXPaywall) {
        updateFeatures(from: remoteConfig)
        updateButtonConfiguration(from: remoteConfig)
        updateTitle(from: remoteConfig)
        updateProducts(from: remoteConfig, fxPaywall: fxPaywall)
        updateButtonColor(from: remoteConfig)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    private func updateFeatures(from remoteConfig: [String: Any]) {
        guard let featuresArray = remoteConfig["features"] as? [String] else { return }
        
        features.removeAll()
        featuresArray.enumerated().forEach {
            features.append(.init(title: $1, iconName: "label\($0+1)"))
        }
    }
    
    private func updateButtonConfiguration(from remoteConfig: [String: Any]) {
        if let buttonTitle = remoteConfig["purchase_button_title"] as? String {
            startFreeTrialButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    private func updateTitle(from remoteConfig: [String: Any]) {
        if let title = remoteConfig["title"] as? String {
            InAppTitle.text = title
        }
    }
    
    private func updateProducts(from remoteConfig: [String: Any], fxPaywall: FXPaywall) {
        guard let productTitleArray = remoteConfig["product_titles"] as? [String],
              let productSubtitleArray = remoteConfig["product_subtitles"] as? [String],
              let fxProducts = fxPaywall.products else { return }
        
        products.removeAll()
        for i in 0..<min(productTitleArray.count, fxProducts.count) {
            guard let price = fxProducts[i].localizedPrice else { continue }
            
            let product = Product(
                identifier: fxProducts[i].productId,
                title: productTitleArray[i].replacingOccurrences(of: "#price#", with: price),
                subTitle: productSubtitleArray[i].replacingOccurrences(of: "#price#", with: price),
                price: price,
                selected: i == 0
            )
            products.append(product)
        }
    }
    
    private func updateButtonColor(from remoteConfig: [String: Any]) {
        if let buttonColor = remoteConfig["purchase_button_color_dark"] as? String {
            startFreeTrialButton.backgroundColor = UIColor(hexString: buttonColor)
        }
    }
    
    
    //MARK: - Functions
    
    func setupViews() {
        view.backgroundColor = UIColor(named: "primary")
        view.addSubview(imageView)
        view.addSubview(InAppTitle)
        view.addSubview(tableView)
        view.addSubview(collectionView)
        view.addSubview(startFreeTrialButton)
        view.addSubview(closeButton)
        view.addSubview(restoreLabel)
        view.addSubview(lineView2)
        view.addSubview(termOfUseLabel)
        view.addSubview(lineView)
        view.addSubview(privacyPolicyLabel)
        view.addSubview(loadingActivityIndicatorView)
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.4),
            
            InAppTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: InAppTitle.bottomAnchor, constant: 24),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: safeArea.widthAnchor,multiplier: 0.87),
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 160),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 15),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 20),
            collectionView.heightAnchor.constraint(equalToConstant: 140),
            
            startFreeTrialButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 15),
            startFreeTrialButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startFreeTrialButton.widthAnchor.constraint(equalToConstant: 350),
            startFreeTrialButton.heightAnchor.constraint(equalToConstant: 50),
            
            lineView.topAnchor.constraint(equalTo: startFreeTrialButton.bottomAnchor, constant: 10),
            lineView.widthAnchor.constraint(equalToConstant: 1),
            lineView.heightAnchor.constraint(equalToConstant: 18),
            lineView.leadingAnchor.constraint(equalTo: startFreeTrialButton.leadingAnchor, constant: 100),
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
            
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            
            loadingActivityIndicatorView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            loadingActivityIndicatorView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            loadingActivityIndicatorView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            loadingActivityIndicatorView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
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
    
    
    
    
    // MARK: - OBJC Functions
    
    @objc func purchaseButtonTapped() {
        PaywallManager.shared.handlePurchaseButtonTapped(
            from: self,
            placementId: placementId,
            fxPaywall: fxPaywall!,
            products: products
        )
    }
    
    private func handlePurchaseSuccess() {
        SessionDataManager.shared.isPremium = true
        
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

        print("Paywall1ViewController: Close button tapped")
        
        guard let remoteConfig = fxPaywall?.remoteConfig else {
            handleNormalClose()
            return
        }
        
        let displayClaimOfferPrompt = remoteConfig["display_claimOffer_prompt"] as? Bool ?? false
        let displayOnClosePaywall = remoteConfig["display_onClose_paywall"] as? Bool ?? false
        
        if displayClaimOfferPrompt {
            print("Paywall1ViewController: Showing claim offer modal")
            showClaimOfferModal()
        } else if displayOnClosePaywall && !isOnClosePaywall {
            print("Paywall1ViewController: Showing onclose paywall")
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
            print("Paywall1ViewController: User tapped 'Not now' - closing all paywalls")
            self.handleNormalClose()
        }
        
        let claimOfferAction = UIAlertAction(title: "Claim Offer", style: .default) { _ in
            print("Paywall1ViewController: User tapped 'Claim Offer' - attempting purchase")
            self.handleClaimOfferPurchase()
        }
        
        alert.addAction(notNowAction)
        alert.addAction(claimOfferAction)
        
        present(alert, animated: true)
    }
    
    private func handleClaimOfferPurchase() {
        guard let fxPaywall = fxPaywall,
              let fxProduct = fxPaywall.products?.first else { return }
        
        loadingActivityIndicatorView.startAnimating()
        loadingActivityIndicatorView.isHidden = false
        
        startFreeTrialButton.isEnabled = false
        closeButton.isEnabled = false
        
        PaywallHelper.shared.purchaseProduct(placementId: placementId, product: fxProduct) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingActivityIndicatorView.stopAnimating()
                self?.loadingActivityIndicatorView.isHidden = true
                self?.startFreeTrialButton.isEnabled = true
                self?.closeButton.isEnabled = true
                
                switch result {
                case .success(let purchaseInfo):
                    print("Paywall1ViewController: Claim offer purchase successful: \(purchaseInfo)")
                    SessionDataManager.shared.isPremium = true
                    self?.handleNormalClose()
                case .failure(let error):
                    print("Paywall1ViewController: Claim offer purchase failed: \(error)")
                    
                    if let remoteConfig = self?.fxPaywall?.remoteConfig,
                       let displayOnClosePaywallFailure = remoteConfig["display_onClose_paywall_failure"] as? Bool,
                       displayOnClosePaywallFailure {
                        print("Paywall1ViewController: display_onClose_paywall_failure is true, showing onClose paywall")
                        self?.showOnClosePaywallAfterFailure()
                    } else {
                        self?.handleNormalClose()
                    }
                }
            }
        }
    }
    
    private func showOnClosePaywall() {
        print("Paywall1ViewController: Showing onclose paywall")
        
        PaywallManager.shared.showOnClosePaywall(from: self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Paywall1ViewController: Onclose paywall shown successfully")
                case .failure(let error):
                    print("Paywall1ViewController: Failed to show onclose paywall: \(error)")
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

        showWebViewContentPage(title: "Terms of Use", contentURL: Constants.URLs.termsOfUse)
    }
    
    @objc func privacyPolicyLabelTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_privacy_tap")

        showWebViewContentPage(title: "Privacy Policy", contentURL: Constants.URLs.privacyPolicy)
    }
    
    @objc func restoreLabelTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_restore")

        self.loadingActivityIndicatorView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
        
        PaywallHelper.shared.restorePurchases { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingActivityIndicatorView.stopAnimating()
                self?.loadingActivityIndicatorView.isHidden = true
                
                switch result {
                case .success(let purchaseInfo):
                    print("Paywall1ViewController: Restore successful: \(purchaseInfo)")
                    self?.handlePurchaseCompleted()
                case .failure(let error):
                    print("Paywall1ViewController: Restore failed: \(error)")
                    self?.showRestoreFailureAlert()
                }
            }
        }
        
        tableView.reloadData()
    }
    
    private func showRestoreFailureAlert() {
        let alert = UIAlertController(title: "Restore Failed", 
                                    message: "No previous purchases found to restore.", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func handlePurchaseCompleted() {
        SessionDataManager.shared.isPremium = true
        
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
}

// MARK: - Extenisons

extension Paywall1ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InAppTableCell.reuseIdentifier, for: indexPath) as! InAppTableCell
        
        cell.configure(with: features[indexPath.row])
        return cell
    }
}

extension Paywall1ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InAppCell.reuseIdentifier, for: indexPath) as? InAppCell else {
            fatalError("Unable to dequeue InAppCell")
        }
        cell.configure(with: products[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 30, height: collectionView.frame.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        products.forEach{ $0.selected = false }
        products[indexPath.row].selected = true
        collectionView.reloadData()
        
        let selectedProduct = products[indexPath.row]
        AnalyticsManager.shared.fxAnalytics.send(event: "select_product", properties: [
            "product_name": selectedProduct.title,
            "product_id": selectedProduct.identifier,
            "placement": placementId,
            "paywall": fxPaywall?.name ?? ""
        ])
    }
}
