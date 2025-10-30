import UIKit

enum NetworkPermissionType {
    case wifiNotConnected
    case localNetworkNotAllowed
}

class NetworkPermissionVC: UIViewController {
    
    var permissionType: NetworkPermissionType = .localNetworkNotAllowed
    
    private let containerView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let settingsButton = UIButton(type: .system)
    private let refreshButton = UIButton(type: .system)
    
    var onPermissionGranted: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Network Permission"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        
        containerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        containerView.layer.cornerRadius = 20
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.image = UIImage(systemName: "wifi.exclamationmark")
        iconView.tintColor = .systemOrange
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "Local Network Permission Required"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.text = "To discover TV devices on your network, please allow local network access in Settings.\n\n1. Tap 'Open Settings' below\n2. Find 'Universal Remote Control' in the list\n3. Enable 'Local Network' permission\n4. Return to the app and tap 'Check Again'"
        messageLabel.textColor = .systemGray
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        settingsButton.setTitle("Open Settings", for: .normal)
        settingsButton.backgroundColor = UIColor(red: 96/255, green: 18/255, blue: 197/255, alpha: 1.0)
        settingsButton.setTitleColor(.white, for: .normal)
        settingsButton.layer.cornerRadius = 12
        settingsButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(openSettingsTapped), for: .touchUpInside)
        
        refreshButton.setTitle("Check Again", for: .normal)
        refreshButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.layer.cornerRadius = 12
        refreshButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addTarget(self, action: #selector(checkAgainTapped), for: .touchUpInside)
        
        view.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(settingsButton)
        containerView.addSubview(refreshButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            settingsButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30),
            settingsButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 200),
            settingsButton.heightAnchor.constraint(equalToConstant: 50),
            
            refreshButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 12),
            refreshButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 200),
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
            refreshButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30)
        ])
    }
    
    @objc private func openSettingsTapped() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    @objc private func checkAgainTapped() {
        print("🔍 Check Again button tapped")
        
        if #available(iOS 14.0, *) {
            LocalNetworkPermissionManager.shared.checkPermission { status in
                DispatchQueue.main.async {
                    print("🔍 Check Again - Permission status: \(status)")
                    
                    switch status {
                    case .granted:
                        print("🔍 Permission granted, dismissing")
                        AnalyticsManager.shared.fxAnalytics.send(event: "local_network_permission_allow")
                        self.dismiss(animated: true) {
                            self.onPermissionGranted?()
                        }
                    case .denied:
                        print("🔍 Permission still denied")
                        AnalyticsManager.shared.fxAnalytics.send(event: "local_network_permission_decline")
                        self.showPermissionStillDeniedAlert()
                    case .notDetermined:
                        print("🔍 Permission not determined")
                        self.showPermissionStillDeniedAlert()
                    case .checking:
                        print("🔍 Permission checking...")
                    }
                }
            }
        } else {
            self.onPermissionGranted?()
        }
    }
    
    private func showPermissionStillDeniedAlert() {
        let alert = UIAlertController(
            title: "Permission Still Required",
            message: "Please make sure you have enabled Local Network permission for Universal Remote Control in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
