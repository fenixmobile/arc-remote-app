//
//  OnboardingVC1.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import UIKit

class OnboardingVC1: UIViewController {
    
    lazy var imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = UIImage(named: "redesign-howto2")
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
        label.text = "Remote Control"
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
        label.text = "Control your Smart TV directly from your \nphone with full functionality."
        label.textAlignment = .center
        label.alpha = 1
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
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "onboarding_2_continue_button"
        button.layer.zPosition = 1
        return button
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageController: UIPageControl = .init()
        pageController.translatesAutoresizingMaskIntoConstraints = false
        pageController.numberOfPages = 3
        pageController.currentPage = 0
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
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "primary")
        view.addSubview(imageView)
        view.addSubview(backgroundImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(subLabel)
        view.addSubview(continueButton)
        // view.addSubview(pageControl)
        
    }
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            
            imageView.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 80),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(greaterThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.57),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 35),
            descriptionLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 300),
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.05),
            
            subLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            subLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            subLabel.widthAnchor.constraint(equalToConstant: 500),
            subLabel.heightAnchor.constraint(greaterThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.1),
            subLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -24),
            
            continueButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 350),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -40),
        ])
    }
    
    func fadeInElements() {
        let offScreenTransform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        
        imageView.transform = offScreenTransform
        imageView.alpha = 0
        
        descriptionLabel.alpha = 1
        subLabel.alpha = 1
        continueButton.alpha = 1

        UIView.animate(withDuration: 10, delay: 0.7, options: .curveLinear, animations: {
            self.imageView.transform = .identity
            self.imageView.alpha = 1
        }, completion: nil)
    }
    
    @objc func continueButtonTapped() {
        if let parentViewController = parent as? PageViewController {
            parentViewController.showNextPage()
        }
    }
}



