//
//  MainTabBarController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(named: "tabbar.line")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarConstraints()
        setupViewControllers()
        checkAndShowMainPaywall()
        delegate = self
    }
    
    private func setupTabBarConstraints() {
        tabBar.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -1),
            lineView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
        ])
    }
    
    private func setupViewControllers() {
        let remoteViewController = TVRemoteViewController()
        let settingsViewController = SettingsViewController()
        
        let viewControllers = [remoteViewController, settingsViewController]
        tabBar.accessibilityIdentifier = "main_tab_bar"
        
        remoteViewController.tabBarItem = UITabBarItem(title: "Remote", image: UIImage(named: "1"), tag: 0)
        remoteViewController.tabBarItem.accessibilityIdentifier = "tab_main"
        
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "3"), tag: 1)
        settingsViewController.tabBarItem.accessibilityIdentifier = "tab_settings"
        
        self.viewControllers = viewControllers
        
        tabBar.backgroundColor = UIColor(named: "tabbar")
        tabBar.layer.zPosition = 1
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .gray
        tabBar.itemWidth = 100
        tabBar.itemPositioning = .centered
    }
    
    private func checkAndShowMainPaywall() {
        guard UserDefaultsManager.shared.hasCompletedOnboarding else { return }
        guard !UserDefaultsManager.shared.shouldSkipNextMainPaywall else { 
            UserDefaultsManager.shared.markMainPaywallShown()
            return 
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            PaywallManager.shared.showDynamicPaywall(placementId: "main", from: self)
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.tabBarItem.tag == 0 {
            AnalyticsManager.shared.fxAnalytics.send(event: "tabbar_remote")
        } else if viewController.tabBarItem.tag == 1 {
            AnalyticsManager.shared.fxAnalytics.send(event: "tabbar_settings")
        }
    }
}

