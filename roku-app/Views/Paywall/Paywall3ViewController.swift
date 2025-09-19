//
//  Paywall3ViewController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import UIKit
import FXFramework

class Paywall3ViewController: UIViewController {
    
    //MARK: - Properties
    
    var fromOnboarding: Bool = false
    var completion: (()->Void)?
    var fxPaywall: FXPaywall?
    var placementId: String
    
    init(placementId: String = "remote") {
        self.placementId = placementId
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
    var onClose: (() -> Void)?
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(modalClosed), name: NSNotification.Name("modalClosed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(termsOfUse), name: NSNotification.Name("termsOfUse"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(privacyPolicy), name: NSNotification.Name("privacyPolicy"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restoreLabelTapped), name: NSNotification.Name("restore"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name("ShowAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showOnClosePaywall), name: NSNotification.Name("ShowOnClosePaywall"), object: nil)
        
        if fxPaywall?.remoteConfig != nil {
            // Set paywall flags from remote config
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: - Functions
    
    private func setupPurchaseCompletion() {
        // Purchase completion handling will be implemented with Adapty
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
        paywall3ModalView.loadingActivityIndicatorView.startAnimating()
        
        // Restore logic will be implemented with Adapty
    }
    
    @objc func modalClosed() {
        paywall3ModalView.loadingActivityIndicatorView.isHidden = true
        paywall3ModalView.loadingActivityIndicatorView.stopAnimating()
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func showAlert(_ notification: Notification) {
        guard let alert = notification.object as? UIAlertController else { return }
        present(alert, animated: true)
    }
    
    @objc func showOnClosePaywall() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            PaywallManager.shared.showPaywall(placement: .onclose, from: self)
        }
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
                    window.makeKeyAndVisible()
                }
            }
        }
    }
}
