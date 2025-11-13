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
        checkAndReconnectSamsungTV()
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
        checkAndReconnectSamsungTV()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        if let splashVC = navigationViewController?.topViewController as? SplashViewController {
            splashVC.appDidEnterBackground()
        }
    }
    
    private func checkAndReconnectSamsungTV() {
        guard let device = TVServiceManager.shared.currentDevice,
              device.brand == .samsung,
              let service = TVServiceManager.shared.currentService as? SamsungTVService else {
            return
        }
        
        Task {
            if let webSocketTask = service.webSocketTask {
                let state = webSocketTask.state
                if state == .canceling || state == .completed {
                    print("🔄 Samsung TV WebSocket durumu: \(state), yeniden bağlanılıyor...")
                    do {
                        try await service.connect()
                    } catch {
                        print("❌ Samsung TV yeniden bağlantı hatası: \(error)")
                        DispatchQueue.main.async {
                            TVServiceManager.shared.currentDevice = nil
                        }
                    }
                } else if !service.isConnected && state == .running {
                    print("🔄 Samsung TV bağlantı durumu tutarsız, yeniden bağlanılıyor...")
                    do {
                        try await service.connect()
                    } catch {
                        print("❌ Samsung TV yeniden bağlantı hatası: \(error)")
                        DispatchQueue.main.async {
                            TVServiceManager.shared.currentDevice = nil
                        }
                    }
                }
            } else if !service.isConnected {
                print("🔄 Samsung TV bağlantısı kopmuş, yeniden bağlanılıyor...")
                do {
                    try await service.connect()
                } catch {
                    print("❌ Samsung TV yeniden bağlantı hatası: \(error)")
                    DispatchQueue.main.async {
                        TVServiceManager.shared.currentDevice = nil
                    }
                }
            }
        }
    }
}
