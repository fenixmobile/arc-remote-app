//
//  SceneDelegate.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var navigationViewController: UINavigationController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let splashViewController = SplashViewController()
        navigationViewController = UINavigationController(rootViewController: splashViewController)
        navigationViewController?.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let splashVC = navigationViewController?.topViewController as? SplashViewController {
            splashVC.appDidBecomeActive()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if let splashVC = navigationViewController?.topViewController as? SplashViewController {
            splashVC.appWillResignActive()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if let splashVC = navigationViewController?.topViewController as? SplashViewController {
            splashVC.appWillEnterForeground()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        if let splashVC = navigationViewController?.topViewController as? SplashViewController {
            splashVC.appDidEnterBackground()
        }
    }
}
