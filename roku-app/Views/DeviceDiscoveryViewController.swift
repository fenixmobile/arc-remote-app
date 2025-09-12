//
//  DeviceDiscoveryViewController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import UIKit
import Combine

class DeviceDiscoveryViewController: UIViewController {
    
    private let tableView = UITableView()
    private let addDeviceButton = UIButton(type: .system)
    private let refreshButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    
    private let viewModel = TVRemoteViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 DeviceDiscoveryViewController: viewDidLoad çağrıldı")
        setupUI()
        setupBindings()
        setupConstraints()
        startDiscovery()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Discover Devices"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCustomDevice)
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: "DeviceCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.backgroundColor = .systemBlue
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.layer.cornerRadius = 8
        refreshButton.addTarget(self, action: #selector(refreshDevices), for: .touchUpInside)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textColor = .systemGray
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        view.addSubview(refreshButton)
        view.addSubview(activityIndicator)
        view.addSubview(messageLabel)
    }
    
    private func setupBindings() {
        // Bind discovered devices
        viewModel.$discoveredDevices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        // Bind connected device IDs
        TVServiceManager.shared.$connectedDeviceIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$discoveryMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.messageLabel.text = message
            }
            .store(in: &cancellables)
        
        // Bind discovery state
        viewModel.$isDiscovering
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDiscovering in
                if isDiscovering {
                    self?.activityIndicator.startAnimating()
                    self?.refreshButton.isEnabled = false
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.refreshButton.isEnabled = true
                }
            }
            .store(in: &cancellables)
        
        // Bind error messages
        viewModel.$showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showError in
                if showError {
                    self?.showErrorAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Refresh button constraints
            refreshButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 120),
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Message label constraints
            messageLabel.topAnchor.constraint(equalTo: refreshButton.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Table view constraints
            tableView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Activity indicator constraints
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func startDiscovery() {
        print("🔍 DeviceDiscoveryViewController: startDiscovery çağrıldı")
        viewModel.startDiscovery()
    }
    
    @objc private func refreshDevices() {
        viewModel.startDiscovery()
    }
    
    @objc private func addCustomDevice() {
        let alert = UIAlertController(title: "Add Custom Device", message: "Enter device details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Device Name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "IP Address"
            textField.keyboardType = .numbersAndPunctuation
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Port (optional)"
            textField.keyboardType = .numberPad
            textField.text = "8080"
        }
        
        let brandPicker = UIAlertController(title: "Select Brand", message: nil, preferredStyle: .actionSheet)
        
        for brand in TVBrand.allCases {
            brandPicker.addAction(UIAlertAction(title: brand.displayName, style: .default) { _ in
                self.showBrandSelectedAlert(brand: brand, alert: alert)
            })
        }
        
        brandPicker.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Select Brand", style: .default) { _ in
            self.present(brandPicker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showBrandSelectedAlert(brand: TVBrand, alert: UIAlertController) {
        guard let nameField = alert.textFields?[0],
              let ipField = alert.textFields?[1],
              let portField = alert.textFields?[2],
              let name = nameField.text, !name.isEmpty,
              let ip = ipField.text, !ip.isEmpty else {
            showErrorAlert(message: "Please fill in all required fields")
            return
        }
        
        let port = Int(portField.text ?? "8080") ?? 8080
        
        viewModel.addCustomDevice(name: name, brand: brand, ipAddress: ip, port: port)
        
        let successAlert = UIAlertController(
            title: "Device Added",
            message: "\(brand.displayName) device added successfully",
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(successAlert, animated: true)
    }
    
    private func showErrorAlert(message: String? = nil) {
        let alert = UIAlertController(
            title: "Error",
            message: message ?? viewModel.errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.viewModel.clearError()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DeviceDiscoveryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceTableViewCell
        let device = viewModel.discoveredDevices[indexPath.row]
        cell.configure(with: device)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DeviceDiscoveryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let device = viewModel.discoveredDevices[indexPath.row]
        
        let alert = UIAlertController(
            title: "Connect to \(device.displayName)",
            message: "Do you want to connect to this device?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Connect", style: .default) { _ in
            print("🔍 DeviceDiscoveryViewController: Connect butonuna basıldı - \(device.name)")
            self.viewModel.connectToDevice(device)
            self.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - DeviceTableViewCell
class DeviceTableViewCell: UITableViewCell {
    private let deviceNameLabel = UILabel()
    private let deviceBrandLabel = UILabel()
    private let deviceIPLabel = UILabel()
    private let deviceIconImageView = UIImageView()
    private let connectionStatusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        deviceNameLabel.font = .boldSystemFont(ofSize: 16)
        deviceBrandLabel.font = .systemFont(ofSize: 14)
        deviceBrandLabel.textColor = .systemBlue
        deviceIPLabel.font = .systemFont(ofSize: 12)
        deviceIPLabel.textColor = .systemGray
        connectionStatusLabel.font = .systemFont(ofSize: 12)
        connectionStatusLabel.textColor = .systemGreen
        
        deviceIconImageView.contentMode = .scaleAspectFit
        deviceIconImageView.tintColor = .systemBlue
        
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceBrandLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceIPLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceIconImageView.translatesAutoresizingMaskIntoConstraints = false
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(deviceIconImageView)
        contentView.addSubview(deviceNameLabel)
        contentView.addSubview(deviceBrandLabel)
        contentView.addSubview(deviceIPLabel)
        contentView.addSubview(connectionStatusLabel)
        
        NSLayoutConstraint.activate([
            deviceIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deviceIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deviceIconImageView.widthAnchor.constraint(equalToConstant: 40),
            deviceIconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            deviceNameLabel.leadingAnchor.constraint(equalTo: deviceIconImageView.trailingAnchor, constant: 12),
            deviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            deviceNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            deviceBrandLabel.leadingAnchor.constraint(equalTo: deviceIconImageView.trailingAnchor, constant: 12),
            deviceBrandLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 4),
            deviceBrandLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            deviceIPLabel.leadingAnchor.constraint(equalTo: deviceIconImageView.trailingAnchor, constant: 12),
            deviceIPLabel.topAnchor.constraint(equalTo: deviceBrandLabel.bottomAnchor, constant: 4),
            deviceIPLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            connectionStatusLabel.leadingAnchor.constraint(equalTo: deviceIconImageView.trailingAnchor, constant: 12),
            connectionStatusLabel.topAnchor.constraint(equalTo: deviceIPLabel.bottomAnchor, constant: 2),
            connectionStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            connectionStatusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with device: TVDevice) {
        deviceNameLabel.text = device.displayName
        deviceBrandLabel.text = device.brand.displayName
        deviceIPLabel.text = "\(device.ipAddress):\(device.port)"
        deviceIconImageView.image = UIImage(systemName: device.brand.iconName)
        
        let isConnected = TVServiceManager.shared.connectedDeviceIds.contains(device.id)
        if isConnected {
            connectionStatusLabel.text = "✅ Connected"
            connectionStatusLabel.textColor = .systemGreen
        } else {
            connectionStatusLabel.text = "⚪ Not connected"
            connectionStatusLabel.textColor = .systemGray
        }
    }
}
