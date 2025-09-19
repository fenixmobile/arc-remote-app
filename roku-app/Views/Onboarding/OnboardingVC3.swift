//
//  OnboardingVC3.swift
//  roku-app
//
//  Created by fnx macbook on 9.02.2024.
//

import Foundation
import UIKit

class OnboardingVC3: UIViewController {
    
    lazy var imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = UIImage(named: "redesign-howto4")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 1
        imageView.layer.zPosition = 0.1
        return imageView
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
    
    lazy var descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Poppins-Bold", size: 28)
        label.textColor = .white
        label.numberOfLines = 1
        label.text = "Keyboard for Search"
        label.textAlignment = .center
        label.alpha = 1.0
        label.layer.zPosition = 1
        return label
    }()
    
    lazy var subLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Poppins-Light", size: 16)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.text = "Type and search content easily with \nthe built-in keyboard interface."
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
        button.accessibilityIdentifier = "onboarding_4_continue_button"
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 1
        return button
    }()
    
    lazy var pgCntrl: UIPageControl = {
        let pageController: UIPageControl = .init()
        pageController.translatesAutoresizingMaskIntoConstraints = false
        pageController.numberOfPages = 3
        pageController.currentPage = 2
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.currentPageIndicatorTintColor = UIColor(named: "primary")
        return pageController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        fadeInElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "primary")
        view.addSubview(imageView)
        view.addSubview(backgroundImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(subLabel)
        view.addSubview(continueButton)
        // view.addSubview(pageCntrl)
        
    }
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            
            imageView.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 80),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            imageView.heightAnchor.constraint(greaterThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.57),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 35),
            descriptionLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 300),
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.05),
            
            subLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            subLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            subLabel.widthAnchor.constraint(equalToConstant: 340),
            subLabel.heightAnchor.constraint(greaterThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.1),
            subLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -24),
            
            continueButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 350),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
            // pageControl.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 15),
            // pageControl.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
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
        if let parentViewController = parent as? PageViewController {
            parentViewController.showNextPage()
        }
    }
}



