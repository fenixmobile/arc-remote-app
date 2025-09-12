//
//  MainTabBarController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 MainTabBarController: viewDidLoad çağrıldı")
        setupTabBar()
        setupViewControllers()
        print("🔍 MainTabBarController: Tab'lar oluşturuldu, seçili tab: \(selectedIndex)")
        print("🔍 MainTabBarController: ViewControllers sayısı: \(viewControllers?.count ?? 0)")
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    private func setupViewControllers() {
        print("🔍 MainTabBarController: setupViewControllers çağrıldı")
        
        // Remote Control Tab
        print("🔍 MainTabBarController: TVRemoteViewController oluşturuluyor")
        let remoteViewController = TVRemoteViewController()
        print("🔍 MainTabBarController: TVRemoteViewController oluşturuldu: \(remoteViewController)")
        let remoteNavController = UINavigationController(rootViewController: remoteViewController)
        remoteNavController.tabBarItem = UITabBarItem(
            title: "Remote",
            image: UIImage(systemName: "tv"),
            selectedImage: UIImage(systemName: "tv.fill")
        )
        print("🔍 MainTabBarController: Remote tab oluşturuldu")
        
        // Device Discovery Tab
        let discoveryViewController = DeviceDiscoveryViewController()
        let discoveryNavController = UINavigationController(rootViewController: discoveryViewController)
        discoveryNavController.tabBarItem = UITabBarItem(
            title: "Devices",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        print("🔍 MainTabBarController: Devices tab oluşturuldu")
        
        // Settings Tab
        let settingsViewController = SettingsViewController()
        let settingsNavController = UINavigationController(rootViewController: settingsViewController)
        settingsNavController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear.fill")
        )
        print("🔍 MainTabBarController: Settings tab oluşturuldu")
        
        viewControllers = [remoteNavController, discoveryNavController, settingsNavController]
        print("🔍 MainTabBarController: ViewControllers ayarlandı")
    }
}

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Device Management"
        case 1:
            return "App Information"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Connected Devices"
                cell.accessoryType = .disclosureIndicator
            case 1:
                cell.textLabel?.text = "Clear All Devices"
                cell.textLabel?.textColor = .systemRed
            case 2:
                cell.textLabel?.text = "Export Device List"
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "About"
                cell.accessoryType = .disclosureIndicator
            case 1:
                cell.textLabel?.text = "Version"
                cell.detailTextLabel?.text = "1.0.0"
            default:
                break
            }
        default:
            break
        }
        
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // Show connected devices
                showConnectedDevices()
            case 1:
                // Clear all devices
                showClearDevicesAlert()
            case 2:
                // Export device list
                showExportOptions()
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                // Show about
                showAbout()
            default:
                break
            }
        default:
            break
        }
    }
    
    private func showConnectedDevices() {
        let alert = UIAlertController(title: "Connected Devices", message: "This feature will show all connected devices", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showClearDevicesAlert() {
        let alert = UIAlertController(
            title: "Clear All Devices",
            message: "Are you sure you want to remove all saved devices?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            // Clear devices logic
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showExportOptions() {
        let alert = UIAlertController(title: "Export Device List", message: "Choose export format", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "JSON", style: .default) { _ in
            // Export as JSON
        })
        
        alert.addAction(UIAlertAction(title: "CSV", style: .default) { _ in
            // Export as CSV
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showAbout() {
        let alert = UIAlertController(
            title: "About TV Remote",
            message: "A universal remote control app for smart TVs.\n\nSupports:\n• Roku TV\n• Fire TV\n• Samsung TV\n• Sony TV\n• LG TV\n• And more...",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
