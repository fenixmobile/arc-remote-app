//
//  SplashViewController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import UIKit

class SplashViewController: UIViewController {
    
    lazy var splashOkImageView: UIImageView = {
        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.image = .init(named: "splash.ok")
        return animationView
    }()
    
    lazy var splashRightImageView: UIImageView = {
        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.image = .init(named: "splash.right")
        return animationView
    }()
    
    lazy var splashLeftImageView: UIImageView = {
        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.image = .init(named: "splash.left")
        return animationView
    }()
    
    lazy var splashUpImageView: UIImageView = {
        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.image = .init(named: "splash.up")
        return animationView
    }()
    
    lazy var splashDownImageView: UIImageView = {
        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.image = .init(named: "splash.down")
        return animationView
    }()
    
    lazy var centerCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = UIColor(named: "splash")
        view.layer.cornerRadius = 30
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        startAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.navigateToMainApp()
        }
    }
    
    private func setupViews() {
        self.view.backgroundColor = UIColor(named: "primary")
        self.view.addSubview(splashOkImageView)
        self.view.addSubview(splashRightImageView)
        self.view.addSubview(splashLeftImageView)
        self.view.addSubview(splashUpImageView)
        self.view.addSubview(splashDownImageView)
        self.view.addSubview(centerCircle)
    }
    
    private func setupConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            splashOkImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            splashOkImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            splashOkImageView.widthAnchor.constraint(equalToConstant: 55),
            splashOkImageView.heightAnchor.constraint(equalToConstant: 55),
            
            splashRightImageView.leadingAnchor.constraint(equalTo: splashOkImageView.trailingAnchor, constant: 3),
            splashRightImageView.centerYAnchor.constraint(equalTo: splashOkImageView.centerYAnchor),
            splashRightImageView.widthAnchor.constraint(equalToConstant: 35),
            splashRightImageView.heightAnchor.constraint(equalToConstant: 78),
            
            splashLeftImageView.trailingAnchor.constraint(equalTo: splashOkImageView.leadingAnchor, constant: -3),
            splashLeftImageView.centerYAnchor.constraint(equalTo: splashOkImageView.centerYAnchor),
            splashLeftImageView.widthAnchor.constraint(equalToConstant: 35),
            splashLeftImageView.heightAnchor.constraint(equalToConstant: 78),
            
            splashUpImageView.bottomAnchor.constraint(equalTo: splashOkImageView.topAnchor, constant: -3),
            splashUpImageView.centerXAnchor.constraint(equalTo: splashOkImageView.centerXAnchor),
            splashUpImageView.widthAnchor.constraint(equalToConstant: 78),
            splashUpImageView.heightAnchor.constraint(equalToConstant: 35),
            
            splashDownImageView.topAnchor.constraint(equalTo: splashOkImageView.bottomAnchor, constant: 3),
            splashDownImageView.centerXAnchor.constraint(equalTo: splashOkImageView.centerXAnchor),
            splashDownImageView.widthAnchor.constraint(equalToConstant: 78),
            splashDownImageView.heightAnchor.constraint(equalToConstant: 35),
            
            centerCircle.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            centerCircle.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            centerCircle.widthAnchor.constraint(equalToConstant: 60),
            centerCircle.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func startAnimation() {
        animateDirectionalArrows()
    }
    
    private func animateDirectionalArrows() {
        let animationSequence = [
            (view: splashRightImageView, duration: 0.5),
            (view: splashDownImageView, duration: 0.7),
            (view: splashLeftImageView, duration: 0.7),
            (view: splashUpImageView, duration: 0.7),
            (view: splashOkImageView, duration: 0.7)
        ]
        
        animateSequence(animationSequence, index: 0)
    }
    
    private func animateSequence(_ sequence: [(view: UIImageView, duration: TimeInterval)], index: Int) {
        guard index < sequence.count else {
            animateCenterCircleAndNavigate()
            return
        }
        
        let currentView = sequence[index].view
        let duration = sequence[index].duration
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            currentView.alpha = 0.0
        }) { _ in
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
                currentView.alpha = 1.0
            }) { _ in
                self.animateSequence(sequence, index: index + 1)
            }
        }
    }
    
    private func animateCenterCircleAndNavigate() {
        centerCircle.alpha = 0.0
        centerCircle.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.centerCircle.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.centerCircle.transform = CGAffineTransform(scaleX: 50, y: 50)
            }) { _ in
                self.navigateToMainApp()
            }
        }
    }
    
    private func navigateToMainApp() {
        guard let window = view.window else { return }
        
        let tabBarController = MainTabBarController()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarController
        }) { _ in
            window.makeKeyAndVisible()
        }
    }
}
