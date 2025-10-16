//
//  OnboardingRatingVC.swift
//  roku-app
//
//  Created by fnx macbook on 21.03.2024.
//

import Foundation
import UIKit
import StoreKit
import FXFramework

class OnboardingRatingVC: UIViewController {
    
    lazy var closeButton: UIButton = {
        let button: UIButton = .init()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.layer.zPosition = 1
        button.setImage(UIImage(named: "close2"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        // button.hitTestEdgeInsets = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        button.isHidden = false
        return button
    }()
    
    lazy var backgroundImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = UIImage(named: "howto-background")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.zPosition = 0
        return imageView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = UIImage(named: "onboarding.rating")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 1
        imageView.layer.zPosition = 1
        return imageView
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Poppins-Bold", size: 28)
        label.textColor = .white
        label.numberOfLines = 1
        label.layer.zPosition = 1
        label.text = "Help Us Grow"
        label.textAlignment = .center
        label.alpha = 1.0
        return label
    }()
    
    lazy var subLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Poppins-Light", size: 16)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.text = "Your feedback helps us improve the app \nand reach more users like you."
        label.alpha = 1
        label.textAlignment = .center
        label.layer.zPosition = 1
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
        button.accessibilityIdentifier = "onboarding_rate_continue_button"
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 1
        return button
    }()
    
    lazy var cntrl: UIPageControl = {
        let pageController: UIPageControl = .init()
        pageController.translatesAutoresizingMaskIntoConstraints = false
        pageController.numberOfPages = 3
        pageController.currentPage = 2
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.currentPageIndicatorTintColor = UIColor(named: "primary")
        return pageController
    }()
    
    lazy var loadingActivityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView: UIActivityIndicatorView = .init()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.color = .white
        return activityIndicatorView
    }()
    
    var rateAppShowed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        fadeInElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loadingActivityIndicatorView.stopAnimating()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "primary")
        view.addSubview(backgroundImageView)
        view.addSubview(closeButton)
        view.addSubview(imageView)
        view.addSubview(descriptionLabel)
        view.addSubview(subLabel)
        view.addSubview(continueButton)
        // view.addSubview(cntrl)
        view.addSubview(loadingActivityIndicatorView)
    }
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            
            imageView.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 80),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.69),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            descriptionLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 340),
            descriptionLabel.heightAnchor.constraint(lessThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.25),
            //            descriptionLabel.heightAnchor.constraint(lessThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.05),
            
            subLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            subLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            subLabel.widthAnchor.constraint(equalToConstant: 340),
            subLabel.heightAnchor.constraint(greaterThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.1),
            subLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -8),
            
            continueButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 350),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
            loadingActivityIndicatorView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            loadingActivityIndicatorView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            loadingActivityIndicatorView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            loadingActivityIndicatorView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            // pageController.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 15),
            // pageController.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
        ])
    }
    
    func fadeInElements() {
        UIView.animate(withDuration: 1.0) {
            self.imageView.alpha = 1
            self.descriptionLabel.alpha = 1
            self.subLabel.alpha = 1
            self.continueButton.alpha = 1
        }
    }
    
    @objc func continueButtonTapped() {
        AnalyticsManager.shared.fxAnalytics.send(event: "rate_continue")
        if !rateAppShowed {
            rateAppShowed = true
            rateApp()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let self = self else { return }
                self.showPaywall()
            }
        } else {
            showPaywall()
        }
    }
    
    private func rateApp() {
        loadingActivityIndicatorView.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now()+2) { [weak self] in
            self?.loadingActivityIndicatorView.stopAnimating()
            self?.showPaywall()
        }
        if ProcessInfo.processInfo.arguments.contains("uitest") {
            return
        }
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReview(in: scene)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @objc func closeButtonTapped() {
        self.showPaywall()
    }
    
    private func showPaywall() {
        UserDefaultsManager.shared.markOnboardingCompleted()
        UserDefaultsManager.shared.markOnboardingPaywallSeen()
        
        PaywallManager.shared.showDynamicPaywall(placementId: "onboarding", from: self)
    }
}



