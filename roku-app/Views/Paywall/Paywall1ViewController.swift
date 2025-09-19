//
//  Paywall1ViewController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import UIKit
import FXFramework
import WebKit
import StoreKit

class Paywall1ViewController: UIViewController, WKNavigationDelegate {
    
    //MARK: - Properties
    
    var selectedIndexPath: IndexPath?
    var configArray: [(key: String, value: Any)] = []
    var features: [PaywallFeature] = []
    var products: [Product] = []
    var webView: WKWebView!
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
    
    // MARK: - PaywallNavigationManager Properties
    var displayClaimOfferAlert: Bool = false
    var displayOncloseModal: Bool = false
    var displayOnclosePaywallFailure: Bool = false
    var closeCompletion: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    //MARK: - UI Elements
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "paywall1")
        return imageView
    }()
    
    lazy var InAppTitle: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "title")
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = UIColor(named: "primary")?.withAlphaComponent(0.5)
        label.text = "Upgrade to Pro"
        label.font = UIFont(name: "Poppins-SemiBold", size: 22)
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(InAppTableCell.self, forCellReuseIdentifier: InAppTableCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isUserInteractionEnabled = false
        tableView.backgroundColor = UIColor(named: "primary")
        tableView.layer.cornerRadius = 25
        return tableView
    }()
    
    lazy var startFreeTrialButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 16)
        button.backgroundColor = UIColor(named: "button")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(startFreeTrialButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close2"), for: .normal)
        button.accessibilityIdentifier = "PaywallCloseButton"
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 2
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(InAppCell.self, forCellWithReuseIdentifier: InAppCell.reuseIdentifier)
        return collectionView
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
        return activityIndicatorView
    }()
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        setupPurchaseCompletion()
        
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
        guard let fxPaywall = fxPaywall else { 
            print("Paywall1ViewController: fxPaywall is nil, waiting for remote config...")
            return 
        }
        
        if let remoteConfig = fxPaywall.remoteConfig {
            print("Paywall1ViewController: Remote config loaded, updating UI...")
            updateUIWithRemoteConfig(remoteConfig: remoteConfig, fxPaywall: fxPaywall)
        } else {
            print("Paywall1ViewController: Remote config is nil, waiting...")
        }
    }
    
    func updateUIWithRemoteConfig(remoteConfig: [String: Any], fxPaywall: FXPaywall) {
        self.configArray = remoteConfig.map { ($0, $1) }
        
        for (key, value) in configArray {
            print("Key: \(key), Value: \(value)")
        }
        
        if let featuresArray = remoteConfig["features"] as? [String] {
            self.features.removeAll()
            featuresArray.enumerated().forEach {
                self.features.append(.init(title: $1, iconName: "label\($0+1)"))
            }
            print("Features Array: \(featuresArray)")
        }
        
        if let paywallButton = remoteConfig["purchase_button_title"] as? String {
            self.startFreeTrialButton.setTitle(paywallButton, for: .normal)
        }
        
        if let paywallTitle = remoteConfig["title"] as? String {
            self.InAppTitle.text = paywallTitle
        }
        
        if let productTitleArray = remoteConfig["product_titles"] as? [String],
           let productSubtitleArray = remoteConfig["product_subtitles"] as? [String],
           let fxProducts = fxPaywall.products {
            self.products.removeAll()
            for i in 0..<min(productTitleArray.count, fxProducts.count) {
              
                guard let price = fxProducts[i].localizedPrice else { continue }
                self.products.append(.init(
                    identifier: fxProducts[i].productId,
                    title: productTitleArray[i].replacingOccurrences(of: "#price#", with: price),
                    subTitle: productSubtitleArray[i].replacingOccurrences(of: "#price#", with: price),
                    price: price,
                    selected: i == 0
                ))
            }
        }
        
        if let paywallButtonColor: String = remoteConfig["purchase_button_color_dark"] as? String {
            self.startFreeTrialButton.backgroundColor = UIColor(hexString: paywallButtonColor)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    //MARK: - Functions
    
    func setupViews() {
        view.backgroundColor = UIColor(named: "primary")
        view.addSubview(imageView)
        view.addSubview(InAppTitle)
        view.addSubview(tableView)
        view.addSubview(collectionView)
        view.addSubview(startFreeTrialButton)
        view.addSubview(collectionView)
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
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func setupPurchaseCompletion() {
    }
    
    private func startClaimOfferPurchase() {
        guard let _ = products.first(where: { $0.selected }),
              let _ = fxPaywall else { return }
    }
    
    // MARK: - OBJC Functions
    
    @objc func startFreeTrialButtonTapped() {
        guard let selectedProduct = products.first(where: {$0.selected }),
              let fxPaywall = fxPaywall,
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
                    print("Paywall1ViewController: Purchase successful: \(purchaseInfo)")
                    self?.handlePurchaseSuccess()
                case .failure(let error):
                    print("Paywall1ViewController: Purchase failed: \(error)")
                    self?.handlePurchaseFailure(error: error)
                }
            }
        }
    }
    
    private func handlePurchaseSuccess() {
        dismiss(animated: true) {
            PaywallManager.shared.navigateToMainApp(from: self)
        }
    }
    
    private func handlePurchaseFailure(error: Error) {
        print("Paywall1ViewController: handlePurchaseFailure called")
        print("Paywall1ViewController: fxPaywall exists: \(fxPaywall != nil)")
        
        guard let paywall = fxPaywall else {
            print("Paywall1ViewController: No fxPaywall available")
            let alert = UIAlertController(title: "Purchase Failed", 
                                        message: "Unable to complete purchase. Please try again.", 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        print("Paywall1ViewController: remoteConfig exists: \(paywall.remoteConfig != nil)")
        
        guard let remoteConfig = paywall.remoteConfig else {
            print("Paywall1ViewController: No remoteConfig available")
            let alert = UIAlertController(title: "Purchase Failed", 
                                        message: "Unable to complete purchase. Please try again.", 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        print("Paywall1ViewController: remoteConfig: \(remoteConfig)")
        
        guard let displayOnClosePaywallFailure = remoteConfig["display_onClose_paywall_failure"] as? Bool else {
            print("Paywall1ViewController: display_onClose_paywall_failure not found or not Bool")
            let alert = UIAlertController(title: "Purchase Failed", 
                                        message: "Unable to complete purchase. Please try again.", 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        print("Paywall1ViewController: display_onClose_paywall_failure: \(displayOnClosePaywallFailure)")
        
        guard displayOnClosePaywallFailure == true else {
            print("Paywall1ViewController: display_onClose_paywall_failure is false, showing alert")
            let alert = UIAlertController(title: "Purchase Failed", 
                                        message: "Unable to complete purchase. Please try again.", 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        if isOnClosePaywall {
            print("Paywall1ViewController: Already onclose paywall, showing alert instead of opening another onclose")
            let alert = UIAlertController(title: "Purchase Failed", 
                                        message: "Unable to complete purchase. Please try again.", 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        print("Paywall1ViewController: display_onClose_paywall_failure is true, dismissing and showing onclose paywall")
        let presentingVC = presentingViewController
        dismiss(animated: true) {
            print("Paywall1ViewController: Dismiss completed, showing onclose paywall")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let presentingVC = presentingVC {
                    PaywallManager.shared.showPaywall(placement: .onclose, from: presentingVC)
                } else {
                    print("Paywall1ViewController: No presenting view controller found")
                }
            }
        }
    }
    
    @objc func closeButtonTapped() {
        print("Paywall1ViewController: Close button tapped")
        if shouldShowOnClosePaywall() {
            print("Paywall1ViewController: Should show onclose paywall")
            showOnClosePaywall()
        } else {
            print("Paywall1ViewController: Normal dismiss")
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func shouldShowOnClosePaywall() -> Bool {
        print("Paywall1ViewController: shouldShowOnClosePaywall - isOnClosePaywall = \(isOnClosePaywall)")
        
        if isOnClosePaywall {
            print("Paywall1ViewController: This is already an onclose paywall, not showing another onclose paywall")
            return false
        }
        
        guard let remoteConfig = fxPaywall?.remoteConfig,
              let displayOnClose = remoteConfig["display_onClose_paywall"] as? Bool else {
            print("Paywall1ViewController: No remote config or display_onClose_paywall not found")
            return false
        }
        print("Paywall1ViewController: display_onClose_paywall = \(displayOnClose)")
        return displayOnClose
    }
    
    private func showOnClosePaywall() {
        print("Paywall1ViewController: Showing onclose paywall")
        
        dismiss(animated: true) { [weak self] in
            PaywallManager.shared.showPaywall(placement: .onclose, from: self?.presentingViewController ?? UIApplication.shared.windows.first?.rootViewController ?? UIViewController()) { result in
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
    }
    
    @objc func termOfUseLabelTapped() {
        showWebViewContentPage(title: "Terms of Use", contentURL: Constants.URLs.termsOfUse)
    }
    
    @objc func privacyPolicyLabelTapped() {
        showWebViewContentPage(title: "Privacy Policy", contentURL: Constants.URLs.privacyPolicy)
    }
    
    @objc func restoreLabelTapped() {
        self.loadingActivityIndicatorView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
        
        tableView.reloadData()
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
    }
}
