//
//  Paywall3ModalView.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import Foundation
import UIKit
import FXFramework
import WebKit
import StoreKit

class Paywall3ModalView: UIView {
    
    //MARK: - Properties
    
    var features: [PaywallFeature] = []
    var products: [Product] = []
    var configArray: [(key: String, value: Any)] = []
    var fxPaywall: FXPaywall?
    var placementId: String = "remote"
    
    //MARK: - UI Elements
    
    private let collectionViewHeight: CGFloat = 200
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Choose your plan to unlock all features"
        label.textColor = .white
        label.font = UIFont(name: "Poppins-Bold", size: 26)
        label.numberOfLines = 2
        return label
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 55)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(Paywall3CollectionViewCell.self, forCellWithReuseIdentifier: Paywall3CollectionViewCell.cellIdentifier)
        collectionView.backgroundColor = UIColor(named: "primary")
        return collectionView
    }()
    
    lazy var continueButton: UIButton = {
        let button: UIButton = .init()
        button.setTitle("Start Free Trial", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "button")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
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
    
    lazy var closeLine: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let button: UIButton = .init()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "onBoardingClose"), for: .normal)
        button.accessibilityIdentifier = "PaywallCloseButton"
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupContraints()
        
        loadPaywallConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    private func setupViews() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = UIColor(named: "primary")
        updateTitleLabelFont()
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(continueButton)
        addSubview(termOfUseLabel)
        addSubview(lineView)
        addSubview(privacyPolicyLabel)
        addSubview(closeLine)
        addSubview(closeButton)
        addSubview(restoreLabel)
        addSubview(lineView2)
        addSubview(loadingActivityIndicatorView)
    }
    
    private func setupContraints() {
        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            closeLine.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            closeLine.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeLine.widthAnchor.constraint(equalToConstant: 40),
            closeLine.heightAnchor.constraint(equalToConstant: 4),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight),
            
            continueButton.bottomAnchor.constraint(equalTo: termOfUseLabel.topAnchor, constant: -12),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 52),
            
            lineView.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 10),
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
            
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            loadingActivityIndicatorView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            loadingActivityIndicatorView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            loadingActivityIndicatorView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            loadingActivityIndicatorView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }
    
    private func updateTitleLabelFont() {
        let currentLanguage = Locale.current.languageCode ?? "en"
        let isSmallDevice = UIScreen.main.bounds.width <= 375
        
        switch currentLanguage {
        case "es", "pt":
            titleLabel.font = UIFont(name: "Poppins-Bold", size: isSmallDevice ? 18 : 22)
        case "en":
            titleLabel.font = UIFont(name: "Poppins-Bold", size: isSmallDevice ? 22 : 26)
        default:
            titleLabel.font = UIFont(name: "Poppins-Bold", size: isSmallDevice ? 18 : 22)
        }
    }
    
    private func loadPaywallConfiguration() {
    }
    
    func updateUIWithRemoteConfig(remoteConfig: [String: Any], fxPaywall: FXPaywall) {
        self.configArray = remoteConfig.map { ($0, $1) }
        
        for (key, value) in configArray {
            print("Paywall3ModalView Key: \(key), Value: \(value)")
        }
        
        if let paywallTitle = remoteConfig["title"] as? String {
            self.titleLabel.text = paywallTitle
        }
        
        if let paywallButton = remoteConfig["purchase_button_title"] as? String {
            self.continueButton.setTitle(paywallButton, for: .normal)
        }
        
        if let paywallButtonColor: String = remoteConfig["purchase_button_color"] as? String {
            self.continueButton.backgroundColor = UIColor(hexString: paywallButtonColor)
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
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    //MARK: - OBJC Functions
    @objc func termOfUseLabelTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_terms_tap")

        NotificationCenter.default.post(name: NSNotification.Name("termsOfUse"), object: nil)
    }
    
    @objc func privacyPolicyLabelTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_privacy_tap")

        NotificationCenter.default.post(name: NSNotification.Name("privacyPolicy"), object: nil)
    }
    
    @objc func restoreLabelTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_restore")

        NotificationCenter.default.post(name: NSNotification.Name("restore"), object: nil)
    }
    
    @objc private func closeButtonTapped() {
        if placementId == "onclose" {
            AnalyticsManager.shared.fxAnalytics.send(event: "onclose_purchase_close")
        } else {
            AnalyticsManager.shared.fxAnalytics.send(event: "paywall_close")
        }

        loadingActivityIndicatorView.isHidden = true
        NotificationCenter.default.post(name: NSNotification.Name("modalClosed"), object: nil)
    }
    
    @objc func continueButtonTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "paywall_purchase_start")

        guard let selectedProduct = products.first(where: { $0.selected }),
              let fxPaywall = fxPaywall,
              let fxProduct = fxPaywall.products?.first else { return }
        
        loadingActivityIndicatorView.startAnimating()
        loadingActivityIndicatorView.isHidden = false
        
        continueButton.isEnabled = false
        closeButton.isEnabled = false
        
        PaywallHelper.shared.purchaseProduct(placementId: placementId, product: fxProduct) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingActivityIndicatorView.stopAnimating()
                self?.loadingActivityIndicatorView.isHidden = true
                self?.continueButton.isEnabled = true
                self?.closeButton.isEnabled = true
                
                switch result {
                case .success(let purchaseInfo):
                    print("Paywall3ModalView: Purchase successful: \(purchaseInfo)")
                    NotificationCenter.default.post(name: NSNotification.Name("PurchaseCompleted"), object: nil)
                case .failure(let error):
                    print("Paywall3ModalView: Purchase failed: \(error)")
                    self?.handlePurchaseFailure(error: error)
                }
            }
        }
    }
    
    private func handlePurchaseFailure(error: Error) {
        guard let paywall = fxPaywall,
              let remoteConfig = paywall.remoteConfig,
              let displayOnClosePaywallFailure = remoteConfig["display_onClose_paywall_failure"] as? Bool,
              displayOnClosePaywallFailure == true else {
            let alert = UIAlertController(title: "Purchase Failed", 
                                        message: "Unable to complete purchase. Please try again.", 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            NotificationCenter.default.post(name: NSNotification.Name("ShowAlert"), object: alert)
            return
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("ShowOnClosePaywall"), object: nil)
    }
}

//MARK: - Extensions

extension Paywall3ModalView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Paywall3CollectionViewCell.cellIdentifier, for: indexPath) as? Paywall3CollectionViewCell else {
            fatalError("Unable to dequeue InAppCell")
        }
        cell.configure(with: products[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        products.forEach{ $0.selected = false }
        products[indexPath.row].selected = true
        collectionView.reloadData()
        guard let selectedProduct = products.first(where: { $0.selected }) else { return }
        print(selectedProduct.identifier)
    }
}
